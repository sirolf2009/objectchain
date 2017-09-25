package com.sirolf2009.objectchain.example.node

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.example.common.model.ClaimUsername
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.node.Node
import java.security.KeyPair
import java.util.List
import java.util.Scanner
import org.apache.logging.log4j.LogManager
import com.sirolf2009.objectchain.network.node.NewMutation

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class ChatNode extends Node {
	
	static val log = LogManager.getLogger(ChatNode)
	val KeyPair keys
	
	new(List<String> trackers, int nodePort, KeyPair keys) {
		super(chatKryo, trackers, nodePort)
		this.keys = keys
	}
	
	override start() {
		super.start()
		log.info("Initialized, running chat...")
		val scanner = new Scanner(System.in)
		while(true) {
			val line = scanner.nextLine()
			val message = new Message() => [
				message = line
			]
			val messageMutation = new Mutation(0, message, keys)
			floatingMutations.add(messageMutation)
			broadcast(new NewMutation() => [
				mutation = messageMutation
			])
		}
	}
	
	override onMutationReceived(Mutation mutation) {
		if(mutation.object instanceof Message) {
			println(mutation.publicKey.encoded.toHexString()+": "+(mutation.object as Message).message)
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
		//trackers are hardcoded in your application, they provide the initial list of peers when a node joins the network
		new ChatNode(#["localhost"], port, Keys.generateAssymetricPair()).start()
	}
	
}