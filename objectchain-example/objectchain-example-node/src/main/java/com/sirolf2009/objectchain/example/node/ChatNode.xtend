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
import java.util.List
import java.util.Scanner
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
	
	/** When we launch the application, we first synchronise to download any missing data. After sync we start running our chat */
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
						// Submit mutation broadcasts something to the other nodes in the network. 
						// These are automatically signed by your keys provided in the constructor of this class
						// And will eventually be included in the blockchain
						submitMutation(claim)
					} else if(line.startsWith("/help")) {
						println("Commands:")
						println("/claim <username>		Claim a username")
					}
				} else {
					val message = new Message() => [
						message = line
					]
					//Same as the submit mutation above, except this one submits a chat message. The other one submits a claim to an username
					submitMutation(message)
				}
			}
		].start()
	}
	
	/**
	 * This is called whenever a block is added to the blockchain. We retrieve its state to see wich messages were included in the block.
	 * See {@link ChatState} for more 
	 */
	override onBranchExpanded() {
		val lastState = blockchain.mainBranch.lastState as ChatState
		println(lastState.newChat.join("\n"))
	}
	
	/**
	 * Our instance of kryo. Note that this is a supplier, because we need a kryo instance for every thread that uses kryo.
	 * We only register our own objects.
	 */
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
