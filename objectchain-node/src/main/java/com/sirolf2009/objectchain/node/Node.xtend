package com.sirolf2009.objectchain.node

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.pool.KryoFactory
import com.esotericsoftware.kryo.pool.KryoPool
import com.esotericsoftware.kryonet.Client
import com.esotericsoftware.kryonet.Connection
import com.esotericsoftware.kryonet.FrameworkMessage.KeepAlive
import com.esotericsoftware.kryonet.KryoSerialization
import com.esotericsoftware.kryonet.Listener
import com.esotericsoftware.kryonet.Server
import com.sirolf2009.objectchain.common.BlockchainPersistence
import com.sirolf2009.objectchain.common.exception.BlockVerificationException
import com.sirolf2009.objectchain.common.exception.BranchExpansionException
import com.sirolf2009.objectchain.common.exception.BranchVerificationException
import com.sirolf2009.objectchain.common.exception.MutationVerificationException
import com.sirolf2009.objectchain.common.interfaces.IHashable
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockChain
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Branch
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.KryoRegistrationNode
import com.sirolf2009.objectchain.network.KryoRegistrationTracker
import com.sirolf2009.objectchain.network.node.NewBlock
import com.sirolf2009.objectchain.network.node.NewMutation
import com.sirolf2009.objectchain.network.node.SyncRequest
import com.sirolf2009.objectchain.network.node.SyncResponse
import com.sirolf2009.objectchain.network.tracker.TrackMe
import com.sirolf2009.objectchain.network.tracker.TrackedNode
import com.sirolf2009.objectchain.network.tracker.TrackerList
import com.sirolf2009.objectchain.network.tracker.TrackerRequest
import java.io.File
import java.net.InetSocketAddress
import java.security.KeyPair
import java.util.ArrayList
import java.util.Arrays
import java.util.Date
import java.util.List
import java.util.Optional
import java.util.Set
import java.util.TreeSet
import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.function.Consumer
import java.util.function.Supplier
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import com.sirolf2009.objectchain.common.exception.TrackerUnreachableException

@Accessors
abstract class Node implements AutoCloseable {

	val Logger log
	val Configuration configuration
	val File saveFile
	val KryoPool kryoPool
	val List<InetSocketAddress> trackers
	val int nodePort
	val KeyPair keys

	val ExecutorService workpool
	val List<Client> clients
	var Server server
	var boolean synchronised

	val BlockChain blockchain
	val Set<Mutation> floatingMutations

	new(Configuration configuration, Supplier<Kryo> kryoSupplier, List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		this(LoggerFactory.getLogger(Node), configuration, kryoSupplier, trackers, nodePort, keys)
	}

	new(Logger log, Configuration configuration, Supplier<Kryo> kryoSupplier, List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		this(log, configuration, new File("data.obc"), kryoSupplier, trackers, nodePort, keys)
	}

	new(Logger log, Configuration configuration, File saveFile, Supplier<Kryo> kryoSupplier, List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		this.log = log
		this.configuration = configuration
		this.saveFile = saveFile
		this.trackers = trackers
		this.nodePort = nodePort
		this.keys = keys
		this.floatingMutations = new TreeSet()
		this.clients = new ArrayList()
		this.workpool = createWorkPool()
		val kryoFactory = new KryoFactory() {
			override create() {
				val kryo = kryoSupplier.get()
				KryoRegistrationNode.register(kryo, configuration)
				return kryo
			}
		}
		kryoPool = new KryoPool.Builder(kryoFactory).softReferences().build()
		if(saveFile.exists) {
			blockchain = kryoPool.run[BlockchainPersistence.load(it, configuration, saveFile)]
		} else {
			this.blockchain = new BlockChain()
		}
	}

	def start() {
		val peers = getTrackedNodes()
		log.info("Received {} peers", peers.size())
		if(peers.size() == 0) {
			synchronised = true
			if(blockchain.mainBranch === null || blockchain.mainBranch.size() == 0) {
				log.warn("No peers found, creating genesis block")
				val genesis = new Block(new BlockHeader(new Hash(newArrayOfSize(0)), new Hash(newArrayOfSize(0)), new Date(), configuration.initialTarget, 0), new TreeSet())
				blockchain.mainBranch = new Branch(genesis, new ArrayList(Arrays.asList(genesis)), new ArrayList(Arrays.asList(configuration.genesisState)))
				onBlockchainExpanded()
			} else {
				log.warn("No peers found, nothing to synchronise")
			}
			onSynchronised()
		} else {
			peers.forEach[connectToNode(it)]
		}
		host()
	}

	def host() {
		log.info("Starting host on {}", nodePort)
		server = new Server(16384, 16384, new KryoSerialization(kryoPool.borrow()))
		server.bind(nodePort)

		server.addListener(new Listener() {

			override synchronized connected(Connection connection) {
				workpool.execute [
					try {
						connection.name = connection.remoteAddressTCP.address.hostAddress + ":" + connection.remoteAddressTCP.port
						log.info("{} connected to us", connection)
						onNewConnection(server.kryo, connection)
					} catch(Exception e) {
						log.error("Failed to initialize new connection with {}", connection, e)
					}
				]
			}

			override received(Connection connection, Object object) {
				workpool.execute [
					try {
						if(object instanceof KeepAlive) {
							return
						}
						handleNewObject(server.kryo, connection, object)
					} catch(Exception e) {
						log.error("Failed to handle new object {} from {}", object, connection, e)
					}
				]
			}

			override synchronized disconnected(Connection connection) {
				workpool.execute [
					try {
						log.info("{} disconnected from us", connection)
						onDisconnected(connection)
					} catch(Exception e) {
						log.error("Failed to disconnect from {}", connection, e)
					}
				]
			}

		})

		server.start()
	}

	def connectToNode(TrackedNode node) {
		connectToNode(node.host, node.port)
	}

	def connectToNode(String host, int port) {
		try {
			log.info("Connecting to peer {}:{}", host, port)
			val client = new Client(16384, 16384, new KryoSerialization(kryoPool.borrow()))
			client.start()

			client.addListener(new Listener() {

				override synchronized connected(Connection connection) {
					workpool.execute [
						try {
							synchronized(clients) {
								clients.add(client)
							}
							connection.name = host + ":" + port
							log.info("Connected to peer {}", connection)
							onNewConnection(client.kryo, connection)
						} catch(Exception e) {
							log.error("Failed to initialize with peer {}:{}", host, port, e)
						}
					]
				}

				override received(Connection connection, Object object) {
					workpool.execute [
						try {
							if(object instanceof KeepAlive) {
								return
							}
							handleNewObject(client.kryo, connection, object)
						} catch(Exception e) {
							log.error("Failed to initialize with peer {}:{}", host, port, e)
						}
					]
				}

				override synchronized disconnected(Connection connection) {
					workpool.execute [
						try {
							log.info("Disconnected from peer {}", connection)
							synchronized(clients) {
								clients.remove(client)
							}
							onDisconnected(connection)
						} catch(Exception e) {
							log.error("Failed to initialize with peer {}:{}", host, port, e)
						}
					]
				}

			})

			client.connect(5000, host, port)
		} catch(Exception e) {
			log.warn("Failed to connect to peer {}:{}", host, port, e)
		}
	}

	def synchronized onNewConnection(Kryo kryo, Connection connection) {
		if(!synchronised) {
			connection.sendTCP(new SyncRequest() => [
				if(blockchain.mainBranch !== null && blockchain.mainBranch.blocks?.length() > 0) {
					lastKnownBlock = Optional.of(blockchain.mainBranch.blocks.last.hash(kryo))
				}
				lastKnownBlock = Optional.empty()
			])
		}
	}

	def void onDisconnected(Connection connection) {
	}

	def handleNewObject(Kryo kryo, Connection connection, Object object) {
		log.trace("{} send {}", connection, object)
		if(object instanceof NewMutation) {
			handleNewMutations(connection, object)
		} else if(object instanceof SyncRequest) {
			handleSyncRequest(kryo, connection, object)
		} else if(object instanceof SyncResponse) {
			handleSyncResponse(connection, object)
		} else if(object instanceof NewBlock) {
			handleNewBlock(connection, object)
		} else {
			log.error("I don't know what to do with {}", object)
		}
	}

	def handleNewMutations(Connection connection, NewMutation newMutation) {
		log.info("{} send new mutation", connection)
		if(!isValid(newMutation.mutation)) {
			log.warn("{} send mutation {}, but it is not valid", connection, newMutation)
			return
		}
		val verificationException = kryoPool.run [ kryo |
			try {
				newMutation.mutation.verify(kryo, configuration)
				return null
			} catch(MutationVerificationException e) {
				return e
			}
		]
		if(verificationException !== null) {
			log.warn("{} send mutation {}, but it could not be verified", connection, newMutation, verificationException)
		}

		if(addMutation(newMutation.getMutation)) {
			onMutationReceived(newMutation.mutation)
			log.info("propagating new mutation")
			broadcast(newMutation, Optional.of(connection))
		}
	}

	def boolean isValid(Mutation mutation) {
		return true
	}

	def boolean addMutation(Mutation mutation) {
		return floatingMutations.add(mutation)
	}

	def void onMutationReceived(Mutation mutation) {
	}

	def handleSyncRequest(Kryo kryo, Connection connection, SyncRequest sync) {
		log.info("{} send sync request", connection)
		if(sync.lastKnownBlock !== null && sync.lastKnownBlock.present) {
			val lastKnownBlock = blockchain.mainBranch.blocks.findFirst[hash(kryo).equals(sync.lastKnownBlock.get())]
			if(lastKnownBlock !== null) {
				val newBlocks = blockchain.mainBranch.blocks.subList(blockchain.mainBranch.blocks.indexOf(lastKnownBlock), blockchain.mainBranch.blocks.size() - 1)
				connection.sendTCP(new SyncResponse() => [
					it.newBlocks = newBlocks.toArray(newArrayOfSize(newBlocks.size()))
					it.floatingMutations = floatingMutations.toArray(newArrayOfSize(floatingMutations.size()))
				])
			} else {
				log.warn("{} wanted to sync with an unknown block")
			}
		} else {
			connection.sendTCP(new SyncResponse() => [
				it.newBlocks = blockchain.mainBranch.blocks.toArray(newArrayOfSize(blockchain.mainBranch.blocks.size()))
				it.floatingMutations = floatingMutations.toArray(newArrayOfSize(floatingMutations.size()))
			])
		}
	}

	def synchronized handleSyncResponse(Connection connection, SyncResponse sync) {
		log.info("{} send sync response", connection)
		if(sync.newBlocks !== null && sync.newBlocks.size() > 0) {
			log.info("Received {} blocks and {} transactions", sync.newBlocks.size(), sync.floatingMutations.size())
			this.floatingMutations.addAll(sync.floatingMutations)
			if(!synchronised) {
				val branch = new Branch(sync.newBlocks.get(0), new ArrayList(sync.newBlocks), new ArrayList())
				if(branch.blocks.size() == 1) {
					if(branch.blocks.get(0).header.previousBlock.getBytes().size() == 0 && branch.blocks.get(0).mutations.size() == 0) {
						synchronised = true
						blockchain.mainBranch = new Branch(sync.newBlocks.get(0), new ArrayList(Arrays.asList(sync.newBlocks.get(0))), new ArrayList(Arrays.asList(configuration.genesisState)))
						log.info("Blockchain has been downloaded")
						onSynchronised()
						onBlockchainExpanded()
					}
				} else {
					try {
						kryoPool.run [
							branch.verify(it, configuration)
							synchronised = true
							blockchain.mainBranch = new Branch(sync.newBlocks.get(0), new ArrayList(Arrays.asList(sync.newBlocks.get(0))), new ArrayList(Arrays.asList(configuration.genesisState)))
							sync.newBlocks.stream().skip(1).forEach[block|blockchain.mainBranch.addBlock(it, configuration, block)]
							log.info("Blockchain has been downloaded")
							onSynchronised()
							onBlockchainExpanded()
							return null
						]
					} catch(BranchVerificationException e) {
						log.error("Failed to verify branch received from syncing", e)
					}
				}
			} else {
				sync.newBlocks.forEach[handleNewBlock(connection, it)]
			}
		} else {
			log.warn("{} send an empty sync response", connection)
		}
	}

	def void onSynchronised() {
	}

	def synchronized handleNewBlock(Connection connection, NewBlock newBlock) {
		handleNewBlock(connection, newBlock.block)
	}

	def synchronized handleNewBlock(Connection connection, Block newBlock) {
		log.info("Received new block")
		if(!isValid(newBlock)) {
			log.warn("{} send block {}, but it is not valid", connection, newBlock)
			return
		}
		kryoPool.run [ kryo |
			try {
				if(blockchain.mainBranch.blocks.last().hash(kryo).equals(newBlock.hash(kryo))) {
					return null
				}
			} catch(Exception e) {
				log.error("failed ", e)
				log.error(blockchain.toString())
			}
			// TODO Reject if duplicate of block we have in any of the three categories
			try {
				newBlock.verify(kryo, configuration)
			} catch(BlockVerificationException e) {
				log.error("Failed to verify new block", e)
				return null
			}
			if(blockchain.mainBranch.canExpandWith(kryo, newBlock)) {
				log.info("New block has been mined")
				try {
					blockchain.mainBranch.addBlock(kryo, configuration, newBlock)
					onBranchExpanded()
					onBlockchainExpanded()
					floatingMutations.removeAll(newBlock.getMutations())
					broadcast(new NewBlock() => [
						block = newBlock
					], Optional.of(connection))
				} catch(BranchExpansionException e) {
					log.error("Received block, but it breaks the main branch verification. branch={}\nblock={}", blockchain.mainBranch.toString(kryo), newBlock.toString(kryo), e)
				}
			} else if(blockchain.sideBranches.findFirst[canExpandWith(kryo, newBlock)] !== null) {
				log.info("New block on side branch has been mined")
				val branch = blockchain.sideBranches.findFirst[canExpandWith(kryo, newBlock)]
				try {
					branch.addBlock(kryo, configuration, newBlock)
					onBranchExpanded()
					onBlockchainExpanded()
					broadcast(new NewBlock() => [
						block = newBlock
					], Optional.of(connection))
					log.error("Added block {}", newBlock.hash(kryo))
				} catch(BranchVerificationException e) {
					log.error("Received block, but it breaks the side branch verification", e)
					return null
				}
				if(blockchain.isBranchLonger(branch)) {
					log.info("Side branch is longer than the main branch. Setting it as the main branch")
					blockchain.promoteBranch(branch)
					onBranchReplace()
					onBlockchainExpanded()
				}
			} else {
				if(blockchain.orphanedBlocks.add(newBlock)) {
					log.info("Received orphan block, sending sync request", connection)
					connection.sendTCP(new SyncRequest() => [
						lastKnownBlock = Optional.of(blockchain.mainBranch.blocks.last.hash(kryo))
					])
					onOrphansExpanded()
					broadcast(new NewBlock() => [
						block = newBlock
					], Optional.of(connection))
				}
			}
			return null
		]
	}

	def boolean isValid(Block block) {
		return true
	}

	def void onBlockchainExpanded() {
	}

	def void onBranchReplace() {
	}

	def void onBranchExpanded() {
	}

	def void onOrphansExpanded() {
	}

	def hash(IHashable object) {
		kryoPool.run[object.hash(it)]
	}

	def submitMutation(Object object) {
		val messageMutation = kryoPool.run[kryo|new Mutation(object, kryo, keys)]
		floatingMutations.add(messageMutation)
		broadcast(new NewMutation() => [
			mutation = messageMutation
		])
		return messageMutation
	}

	def broadcast(Object object) {
		broadcast(object, Optional.empty())
	}

	def synchronized broadcast(Object object, Optional<Connection> skip) {
		log.info("Broadcasting {}", object.class)
		log.trace("Broadcasting {}", object)
		val Consumer<Connection> send = [
			if(!skip.isPresent || it != skip.get()) {
				log.trace("sending {} to {}", object, it)
				sendTCP(object)
			}
		]
		server.connections.parallelStream().forEach(send)
		synchronized(clients) {
			clients.parallelStream().forEach(send)
		}
	}

	def getTrackedNodes() {
		val trackerLists = trackers.map[
			try {
				return getTrackedNodes(it)
			} catch(TrackerUnreachableException e) {
				return e
			}
		]
		val trackerResponses = trackerLists.filter[it instanceof TrackerList].map[it as TrackerList].map[tracked].flatten().toSet()
		if(trackerResponses.size() > 0) {
			return trackerResponses
		} else {
			val errorOpt = trackerLists.filter[it instanceof TrackerUnreachableException].map[it as TrackerUnreachableException].toList().stream().findFirst()
			if(errorOpt.isPresent()) {
				throw errorOpt.get()
			}
		}
		return #{} 
	}

	def getTrackedNodes(InetSocketAddress tracker) {
		try {
			log.info("Connecting to tracker {}", tracker)
			val queue = new ArrayBlockingQueue<TrackerList>(1)
			val client = new Client()
			client.start()

			KryoRegistrationTracker.register(client.kryo)

			client.addListener(new Listener() {

				override connected(Connection connection) {
					log.info("Connected to {}, sending request", tracker)
					connection.sendTCP(new TrackerRequest())
					connection.sendTCP(new TrackMe() => [
						it.nodePort = nodePort
					])
				}

				override received(Connection connection, Object object) {
					if(object instanceof TrackerList) {
						log.info("Received tracker response")
						queue.add(object)
					}
				}

				override disconnected(Connection connection) {
					log.info("Disconnect from tracker {}", connection)
				}

			})

			client.connect(5000, tracker.address.hostAddress, tracker.port)
			return queue.take()
		} catch(Exception e) {
			throw new TrackerUnreachableException(tracker, e)
		}
	}

	def createWorkPool() {
		return Executors.newWorkStealingPool()
	}

	def save() {
		kryoPool.run [ kryo |
			val tmpFile = new File(saveFile.absolutePath + ".tmp")
			BlockchainPersistence.save(kryo, blockchain, tmpFile)
			saveFile.delete()
			tmpFile.renameTo(saveFile)
			null
		]
	}

	override close() throws Exception {
		server.close()
		synchronized(clients) {
			val itr = clients.clone.iterator
			while(itr.hasNext()) {
				itr.next().close()
			}
		}
	}

}
