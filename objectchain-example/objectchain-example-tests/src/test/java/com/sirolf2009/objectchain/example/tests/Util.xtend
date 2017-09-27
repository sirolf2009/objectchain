package com.sirolf2009.objectchain.example.tests

import com.sirolf2009.objectchain.example.common.model.ClaimUsername
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.node.Node
import java.util.concurrent.atomic.AtomicReference

class Util {
	
	def static printBlockChain(AtomicReference<ChatNode> node) {
		node.get().printBlockChain()
	}
	
	def static printBlockChain(Node node) {
		println("####################BLOCKS####################")
		node.blockchain.mainBranch.blocks.forEach [
			println(it.toString(node.kryo))
		]
		println("#################TRANSACTIONS#################")
		node.floatingMutations.forEach [
			println(it.toString(node.kryo))
		]
	}

	def static say(AtomicReference<ChatNode> node, String msg) {
		node.say(msg, 200)
	}

	def static say(AtomicReference<ChatNode> node, String msg, long timeout) {
		node.get().submitMutation(new Message() => [
			message = msg
		])
		Thread.sleep(timeout)
	}
	
	def static claim(AtomicReference<ChatNode> node, String user) {
		node.claim(user, 2000)
	}

	def static claim(AtomicReference<ChatNode> node, String user, long timeout) {
		node.get().submitMutation(new ClaimUsername() => [
			username = user
		])
		Thread.sleep(timeout)
	}
	
}