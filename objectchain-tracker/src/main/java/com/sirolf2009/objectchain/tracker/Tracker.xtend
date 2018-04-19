package com.sirolf2009.objectchain.tracker

import com.esotericsoftware.kryonet.Connection
import com.esotericsoftware.kryonet.FrameworkMessage.KeepAlive
import com.esotericsoftware.kryonet.Listener
import com.esotericsoftware.kryonet.Server
import com.sirolf2009.objectchain.network.KryoRegistrationTracker
import com.sirolf2009.objectchain.network.tracker.TrackMe
import com.sirolf2009.objectchain.network.tracker.TrackedNode
import com.sirolf2009.objectchain.network.tracker.TrackerList
import java.util.TreeSet
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.LoggerFactory
import com.sirolf2009.objectchain.network.tracker.TrackerRequest
import com.sirolf2009.objectchain.network.tracker.UntrackMe
import java.util.Collections
import java.util.stream.Collectors
import com.sirolf2009.objectchain.tracker.Tracker.TrackedConnectionNode

class Tracker implements AutoCloseable {
	
	static val log = LoggerFactory.getLogger(Tracker)
	val int port
	val nodes = Collections.synchronizedSet(new TreeSet<TrackedConnectionNode>())
	val Server server
	
	new(int port) {
		this.port = port

		server = new Server()
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
				if(object instanceof TrackMe) {
					nodes.add(new TrackedConnectionNode(new TrackedNode() => [
						it.host = connection.remoteAddressTCP.address.hostAddress
						it.port = object.nodePort
					], connection))
					log.debug("added {}:{} to the tracker list", connection, object.nodePort)
				} else if(object instanceof UntrackMe) {
					nodes.stream().filter[node| node.connection == connection && node.node.port == port].findFirst().ifPresent[
						nodes.remove(it)
						log.debug("removed {}:{} from the tracker list", connection, object.nodePort)
					]
				} else if(object instanceof TrackerRequest) {
					log.info("{} requested tracker list", connection)
					val response = new TrackerList() => [
						tracked = nodes.map[node].toList()
					]
					connection.sendTCP(response)
				}
			}
			
			override disconnected(Connection connection) {
				log.info("{} disconnected", connection)
				nodes.removeAll(nodes.stream().filter[node| node.connection == connection].collect(Collectors.toList()))
			}

		})
	}
	
	
	def start() {
		log.info("Starting tracker")
		server.start()
	}
	
	@Data static class TrackedConnectionNode implements Comparable<TrackedConnectionNode> {
		val TrackedNode node
		val Connection connection
		
		override compareTo(TrackedConnectionNode o) {
			return (connection.toString()+":"+node.getPort()).compareTo(o.connection.toString()+":"+o.node.getPort())
		}
		
	}
	
	override close() throws Exception {
		server.close()
	}

}
