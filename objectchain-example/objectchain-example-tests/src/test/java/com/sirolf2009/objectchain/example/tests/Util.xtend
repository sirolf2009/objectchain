package com.sirolf2009.objectchain.example.tests

import com.sirolf2009.objectchain.example.common.model.ChatState
import com.sirolf2009.objectchain.example.common.model.ClaimUsername
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.example.tracker.ChatTracker
import com.sirolf2009.objectchain.node.Node
import java.util.concurrent.atomic.AtomicReference
import com.sirolf2009.objectchain.example.miner.ChatMiner

class Util {
	
	def static printState(Node node) {
		println("####################STATE####################")
		val state = node.blockchain.mainBranch.lastState as ChatState
		println(state.chat.join("\n"))
	}
	
	def static printBlockChain(AtomicReference<ChatNode> node) {
		node.get().printBlockChain()
	}
	
	def static printBlockChain(Node node) {
		println("####################BLOCKS####################")
		node.blockchain.mainBranch.blocks.forEach [
			node.kryoPool.run[kryo|
				println(it.toString(kryo))
			]
		]
		println("#################TRANSACTIONS#################")
		node.floatingMutations.forEach [
			node.kryoPool.run[kryo|
				println(it.toString(kryo))
			]
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

	def close(ChatTracker tracker) {
		try {
			tracker.close()
		} catch(Exception e) {
		}
	}

	def close(ChatNode node) {
		try {
			node.close()
		} catch(Exception e) {
		}
	}

	def close(ChatMiner miner) {
		try {
			miner.close()
		} catch(Exception e) {
		}
	}
	
}