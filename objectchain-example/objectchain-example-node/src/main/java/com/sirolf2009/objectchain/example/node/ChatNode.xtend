package com.sirolf2009.objectchain.example.node

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.example.common.model.ClaimUsername
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.node.Node
import java.security.KeyPair
import java.util.HashMap
import java.util.List
import java.util.Scanner
import org.apache.logging.log4j.LogManager

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class ChatNode extends Node {

	static val log = LogManager.getLogger(ChatNode)
	val usernames = new HashMap()

	new(List<String> trackers, int nodePort, KeyPair keys) {
		super(chatKryo, trackers, nodePort, keys)
	}

	override start() {
		super.start()
		log.info("Initialized, running chat...")
		val scanner = new Scanner(System.in)
		while(true) {
			val line = scanner.nextLine()

			if(line.startsWith("/")) {
				if(line.startsWith("/claim")) {
					val claim = new ClaimUsername() => [
						username = line.replaceFirst("/claim", "").trim()
					]
					submitMutation(claim)
				} else if(line.startsWith("/help")) {
					println("Commands:")
					println("/claim <username>		Claim a username")
				}
			} else {
				val message = new Message() => [
					message = line
				]
				submitMutation(message)
			}
		}
	}

	override onMutationReceived(Mutation mutation) {
		if(mutation.object instanceof Message) {
			val publicKeyHex = mutation.publicKey.encoded.toHexString()
			println('''«usernames.getOrDefault(publicKeyHex, publicKeyHex)»: «(mutation.object as Message).message»''')
		} else if(mutation.object instanceof ClaimUsername) {
			val publicKeyHex = mutation.publicKey.encoded.toHexString()
			val username = (mutation.object as ClaimUsername).username
			usernames.put(publicKeyHex, username)
			println('''«publicKeyHex» is now known as «username»''')
		}
	}

	def static getChatKryo() {
		return new Kryo() => [
			register(Message)
			register(ClaimUsername)
		]
	}

	def static void main(String[] args) {
		val port = {
			if(args.length() > 0) {
				Integer.parseInt(args.get(0))
			} else {
				4567
			}
		}
		// trackers are hardcoded in your application, they provide the initial list of peers when a node joins the network
		new ChatNode(#["localhost"], port, Keys.generateAssymetricPair()).start()
	}

}
