package com.sirolf2009.objectchain.tracker

import com.esotericsoftware.kryonet.Connection
import com.esotericsoftware.kryonet.Listener
import com.esotericsoftware.kryonet.Server
import com.sirolf2009.objectchain.network.KryoRegistrationTracker
import com.sirolf2009.objectchain.network.tracker.TrackedNode
import com.sirolf2009.objectchain.network.tracker.TrackerList
import com.sirolf2009.objectchain.network.tracker.TrackerRequest
import java.util.TreeSet
import org.slf4j.LoggerFactory
import com.esotericsoftware.kryonet.FrameworkMessage.KeepAlive

class Tracker {
	
	static val log = LoggerFactory.getLogger(Tracker)
	val int port
	val nodes = new TreeSet<TrackedNode>()
	
	new(int port) {
		this.port = port
	}
	
	def start() {
		log.info("Starting tracker")

		val server = new Server()
		KryoRegistrationTracker.register(server.kryo)
		server.bind(port)

		server.addListener(new Listener() {
			
			override connected(Connection connection) {
				connection.name = connection.remoteAddressTCP.address.hostAddress
				log.info("{} connected", connection)
			}
			
			override received(Connection connection, Object object) {
				if(object instanceof KeepAlive) {
					return
				}
				log.debug("{} send {}", connection, object)
				if(object instanceof TrackerRequest) {
					log.info("{} requested tracker list", connection)
					val response = new TrackerList() => [
						tracked = nodes.toList()
					]
					connection.sendTCP(response)
					nodes.add(new TrackedNode() => [
						it.host = connection.remoteAddressTCP.address.hostAddress
						it.port = object.nodePort
					])
					log.debug("send {} the tracker list", connection)
				}
			}
			
			override disconnected(Connection connection) {
				log.info("{} disconnected", connection)
			}

		})
		
		server.start()
	}

}
