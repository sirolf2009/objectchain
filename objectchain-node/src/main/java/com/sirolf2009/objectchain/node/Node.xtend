package com.sirolf2009.objectchain.node

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryonet.Client
import com.esotericsoftware.kryonet.Connection
import com.esotericsoftware.kryonet.FrameworkMessage.KeepAlive
import com.esotericsoftware.kryonet.Listener
import com.esotericsoftware.kryonet.Server
import com.sirolf2009.objectchain.common.model.BlockChain
import com.sirolf2009.objectchain.network.KryoRegistrationNode
import com.sirolf2009.objectchain.network.KryoRegistrationTracker
import com.sirolf2009.objectchain.network.node.SyncRequest
import com.sirolf2009.objectchain.network.node.SyncResponse
import com.sirolf2009.objectchain.network.tracker.TrackedNode
import com.sirolf2009.objectchain.network.tracker.TrackerList
import com.sirolf2009.objectchain.network.tracker.TrackerRequest
import java.util.ArrayList
import java.util.List
import java.util.Optional
import java.util.Set
import java.util.TreeSet
import java.util.concurrent.ArrayBlockingQueue
import java.util.function.Consumer
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import org.eclipse.xtend.lib.annotations.Accessors
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.node.NewMutation

@Accessors
class Node {

	static val log = LoggerFactory.getLogger(Node)
	val Kryo kryo
	val List<String> trackers
	val int nodePort
	
	val List<Client> clients
	var Server server
	var boolean synchronised
	
	val BlockChain blockchain
	val Set<Mutation> floatingMutations

	new(Kryo kryo, List<String> trackers, int nodePort) {
		this.kryo = kryo
		this.trackers = trackers
		this.nodePort = nodePort
		this.floatingMutations = new TreeSet()
		this.clients = new ArrayList()
		this.blockchain = new BlockChain(kryo, new ArrayList())
	}

	def start() {
		getTrackedNodes().forEach[connectToNode(it)]
		host()
	}

	def host() {
		log.info("Starting host on {}", nodePort)
		server = new Server()
		KryoRegistrationNode.register(server.kryo)
		server.bind(nodePort)

		server.addListener(new Listener() {

			override connected(Connection connection) {
				connection.name = connection.remoteAddressTCP.address.hostAddress+":"+connection.remoteAddressTCP.port
				log.info("{} connected to us", connection)
				onNewConnection(connection)
			}

			override received(Connection connection, Object object) {
				if(object instanceof KeepAlive) {
					return
				}
				handleNewObject(connection, object)
			}

			override disconnected(Connection connection) {
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
			val client = new Client()
			client.start()
			KryoRegistrationNode.register(client.kryo)

			client.addListener(new Listener() {

				override connected(Connection connection) {
					connection.name = host + ":" + port
					log.info("Connected to peer {}", connection)
					onNewConnection(connection)
				}

				override received(Connection connection, Object object) {
					if(object instanceof KeepAlive) {
						return
					}
					handleNewObject(connection, object)
				}

				override disconnected(Connection connection) {
					log.info("Disconnected from peer {}", connection)
				}

			})

			client.connect(5000, host, port)
		} catch(Exception e) {
			log.warn("Failed to connect to peer {}:{}", host, port)
		}
	}
	
	def synchronized onNewConnection(Connection connection) {
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

	def handleNewObject(Connection connection, Object object) {
		log.debug("{} send {}", connection, object)
		if(object instanceof NewMutation) {
			handleNewMutations(connection, object)
		} if(object instanceof SyncResponse) {
			handleSyncResponse(connection, object)
		} else {
			log.error("I don't know what to do with {}", object)
		}
	}

	def handleNewMutations(Connection connection, NewMutation newMutations) {
		log.info("{} send new mutation {}", connection, newMutations.getMutations.hash(kryo).toHexString())
		if(newMutations.getMutations.verifySignature()) {
			if(floatingMutations.add(newMutations.getMutations)) {
				log.info("propagating new mutation")
				broadcast(newMutations.getMutations, Optional.of(connection))
			}
		} else {
			log.warn("{} send mutation {}, but I could not verify the signature!", connection, newMutations)
		}
	}

	def handleSyncResponse(Connection connection, SyncResponse sync) {
		log.info("{} send sync response", connection)
		if(sync.newBlocks !== null && sync.newBlocks.size() > 0) {
			blockchain.blocks.addAll(sync.newBlocks)
		}
	}
	
	def broadcast(Object object) {
		broadcast(object, Optional.empty())
	}

	def broadcast(Object object, Optional<Connection> skip) {
		log.info("Broadcasting " + object)
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
