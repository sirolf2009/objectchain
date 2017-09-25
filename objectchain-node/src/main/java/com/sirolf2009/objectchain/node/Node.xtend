package com.sirolf2009.objectchain.node

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryonet.Client
import com.esotericsoftware.kryonet.Connection
import com.esotericsoftware.kryonet.FrameworkMessage.KeepAlive
import com.esotericsoftware.kryonet.KryoSerialization
import com.esotericsoftware.kryonet.Listener
import com.esotericsoftware.kryonet.Server
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockChain
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.KryoRegistrationNode
import com.sirolf2009.objectchain.network.KryoRegistrationTracker
import com.sirolf2009.objectchain.network.node.NewMutation
import com.sirolf2009.objectchain.network.node.SyncRequest
import com.sirolf2009.objectchain.network.node.SyncResponse
import com.sirolf2009.objectchain.network.tracker.TrackedNode
import com.sirolf2009.objectchain.network.tracker.TrackerList
import com.sirolf2009.objectchain.network.tracker.TrackerRequest
import java.math.BigInteger
import java.security.KeyPair
import java.util.ArrayList
import java.util.Date
import java.util.List
import java.util.Optional
import java.util.Set
import java.util.TreeSet
import java.util.concurrent.ArrayBlockingQueue
import java.util.function.Consumer
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory
import com.sirolf2009.objectchain.network.node.NewBlock

@Accessors
abstract class Node {

	static val log = LoggerFactory.getLogger(Node)
	val Kryo kryo
	val List<String> trackers
	val int nodePort
	val KeyPair keys

	val List<Client> clients
	var Server server
	var boolean synchronised

	val BlockChain blockchain
	val Set<Mutation> floatingMutations

	new(Kryo kryo, List<String> trackers, int nodePort, KeyPair keys) {
		this.kryo = kryo
		this.trackers = trackers
		this.nodePort = nodePort
		this.keys = keys
		this.floatingMutations = new TreeSet()
		this.clients = new ArrayList()
		this.blockchain = new BlockChain(new ArrayList())
		KryoRegistrationNode.register(kryo)
	}

	def start() {
		val peers = getTrackedNodes()
		log.info("Received {} peers", peers.size())
		if(peers.size() == 0) {
			synchronised = true
			log.info("No peers found, creating genesis block")
			val genesis = new Block(new BlockHeader(newArrayOfSize(0), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 0), new TreeSet())
			blockchain.blocks.add(genesis)
			onSynchronised()
		} else {
			peers.forEach[connectToNode(it)]
		}
		host()
	}

	def host() {
		log.info("Starting host on {}", nodePort)
		server = new Server(16384, 2048, new KryoSerialization(kryo))
		server.bind(nodePort)

		server.addListener(new Listener() {

			override synchronized connected(Connection connection) {
				connection.name = connection.remoteAddressTCP.address.hostAddress + ":" + connection.remoteAddressTCP.port
				log.info("{} connected to us", connection)
				onNewConnection(server.kryo, connection)
			}

			override received(Connection connection, Object object) {
				if(object instanceof KeepAlive) {
					return
				}
				handleNewObject(server.kryo, connection, object)
			}

			override synchronized disconnected(Connection connection) {
				log.info("{} disconnected from us", connection)
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
			val client = new Client(16384, 2048, new KryoSerialization(kryo))
			client.start()

			client.addListener(new Listener() {

				override synchronized connected(Connection connection) {
					clients.add(client)
					connection.name = host + ":" + port
					log.info("Connected to peer {}", connection)
					log.info("Connected to {} peer", clients.size())
					onNewConnection(client.kryo, connection)
				}

				override received(Connection connection, Object object) {
					if(object instanceof KeepAlive) {
						return
					}
					handleNewObject(client.kryo, connection, object)
				}

				override synchronized disconnected(Connection connection) {
					log.info("Disconnected from peer {}", connection)
					clients.remove(client)
				}

			})

			client.connect(5000, host, port)
		} catch(Exception e) {
			log.warn("Failed to connect to peer {}:{}", host, port, e)
		}
	}

	def synchronized onNewConnection(Kryo kryo, Connection connection) {
		if(!synchronised) {
			synchronised = true
			connection.sendTCP(new SyncRequest() => [
				if(blockchain.blocks.length() > 0) {
					lastKnownBlock = Optional.of(blockchain.blocks.last.hash(kryo))
				}
				lastKnownBlock = Optional.empty()
			])
		}
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
		if(newMutation.getMutation.verifySignature()) {
			onMutationReceived(newMutation.mutation)
			if(floatingMutations.add(newMutation.getMutation)) {
				log.info("propagating new mutation")
				broadcast(newMutation.getMutation, Optional.of(connection))
			}
		} else {
			log.warn("{} send mutation {}, but I could not verify the signature!", connection, newMutation)
		}
	}

	def void onMutationReceived(Mutation mutation) {
	}

	def handleSyncRequest(Kryo kryo, Connection connection, SyncRequest sync) {
		log.info("{} send sync request", connection)
		if(sync.lastKnownBlock !== null && sync.lastKnownBlock.present) {
			val lastKnownBlock = blockchain.blocks.findFirst[hash(kryo).equals(sync.lastKnownBlock.get())]
			if(lastKnownBlock !== null) {
				val newBlocks = blockchain.blocks.subList(blockchain.blocks.indexOf(lastKnownBlock), blockchain.blocks.size() - 1)
				connection.sendTCP(new SyncResponse() => [
					it.newBlocks = newBlocks.toArray(newArrayOfSize(newBlocks.size()))
					it.floatingMutations = floatingMutations.toArray(newArrayOfSize(floatingMutations.size()))
				])
			} else {
				log.warn("{} wanted to sync with an unknown block")
			}
		} else {
			connection.sendTCP(new SyncResponse() => [
				it.newBlocks = blockchain.blocks.toArray(newArrayOfSize(blockchain.blocks.size()))
				it.floatingMutations = floatingMutations.toArray(newArrayOfSize(floatingMutations.size()))
			])
		}
	}

	def synchronized handleSyncResponse(Connection connection, SyncResponse sync) {
		log.info("{} send sync response", connection)
		if(sync.newBlocks !== null && sync.newBlocks.size() > 0) {
			if(!synchronised) {
				if(new BlockChain(sync.newBlocks).verify(kryo, 0)) {
					synchronised = true
					blockchain.blocks.addAll(sync.newBlocks)
					log.info("Blockchain has been downloaded")
					onSynchronised()
				}
			} else {
				val newBlocks = new ArrayList(blockchain.blocks)
				newBlocks += sync.newBlocks
				val newBlockchain = new BlockChain(newBlocks)
				if(newBlockchain.blocks.size() == 1) {
					blockchain.blocks += sync.newBlocks
					log.info("Received genesis block")
					onSynchronised()
				} else if(newBlockchain.verify(kryo, blockchain.blocks.size() - 1)) {
					blockchain.blocks += sync.newBlocks
					log.info("Blockchain has been synchronised")
					onSynchronised()
				} else {
					// TODO handle branching
				}
			}
		} else {
			log.warn("{} send an empty sync response", connection)
		}
	}

	def void onSynchronised() {
	}

	def synchronized handleNewBlock(Connection connection, NewBlock newBlock) {
		if(newBlock.block.verify(kryo)) {
			if(newBlock.block.canExpand(kryo, blockchain)) {
				log.info("New block has been mined")
				blockchain.blocks.add(newBlock.block)
				onBlockchainExpanded()
			} else {
				log.info("Unexpected block was mined, sending sync request", connection)
				connection.sendTCP(new SyncRequest() => [
					lastKnownBlock = Optional.of(blockchain.blocks.last.hash(kryo))
				])
			}
		} else {
			log.warn("{} send new block {}, but I could not verify the integrity!", connection, newBlock)
		}
	}

	def void onBlockchainExpanded() {
	}

	def submitMutation(Object object) {
		val messageMutation = new Mutation(object, keys)
		floatingMutations.add(messageMutation)
		broadcast(new NewMutation() => [
			mutation = messageMutation
		])
	}

	def broadcast(Object object) {
		broadcast(object, Optional.empty())
	}

	def synchronized broadcast(Object object, Optional<Connection> skip) {
		log.trace("Broadcasting {}", object)
		val Consumer<Connection> send = [
			if(!skip.isPresent || it != skip.get()) {
				log.debug("sending {} to {}", object, it)
				sendTCP(object)
			}
		]
		server.connections.parallelStream().forEach(send)
		clients.parallelStream().forEach(send)
	}

	def getTrackedNodes() {
		return trackers.map[getTrackedNodes(it)].map[tracked].flatten.toSet()
	}

	def getTrackedNodes(String tracker) {
		log.info("Connecting to tracker {}", tracker)
		val queue = new ArrayBlockingQueue<TrackerList>(1)
		val client = new Client()
		client.start()

		KryoRegistrationTracker.register(client.kryo)

		client.addListener(new Listener() {

			override connected(Connection connection) {
				log.info("Connected to {}, sending request", tracker)
				connection.sendTCP(new TrackerRequest() => [
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

		client.connect(5000, tracker, 2012)
		return queue.take()
	}

}
