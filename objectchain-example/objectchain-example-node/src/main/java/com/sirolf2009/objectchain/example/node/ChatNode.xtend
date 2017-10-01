package com.sirolf2009.objectchain.example.node

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.example.common.model.ChatConfiguration
import com.sirolf2009.objectchain.example.common.model.ChatState
import com.sirolf2009.objectchain.example.common.model.ClaimUsername
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.node.Node
import java.security.KeyPair
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Scanner
import java.util.Stack
import org.slf4j.Logger

class ChatNode extends Node {

	new(List<String> trackers, int nodePort, KeyPair keys) {
		super(new ChatConfiguration(), [chatKryo], trackers, nodePort, keys)
	}

	new(Logger logger, List<String> trackers, int nodePort, KeyPair keys) {
		super(logger, new ChatConfiguration(), [chatKryo], trackers, nodePort, keys)
	}

	new(Logger logger, Configuration configuration, List<String> trackers, int nodePort, KeyPair keys) {
		super(logger, configuration, [chatKryo], trackers, nodePort, keys)
	}
	
	override getOriginalState() {
		return new ChatState(new ArrayList(), new Stack(), new HashMap())
	}

	override onSynchronised() {
		new Thread [
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
		].start()
	}
	
	override onBranchExpanded() {
		val lastState = blockchain.mainBranch.lastState as ChatState
		println(lastState.newChat.join("\n"))
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
