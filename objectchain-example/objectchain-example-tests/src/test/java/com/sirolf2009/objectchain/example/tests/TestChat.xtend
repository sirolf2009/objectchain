package com.sirolf2009.objectchain.example.tests

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.example.miner.ChatMiner
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.example.tracker.ChatTracker
import java.util.concurrent.atomic.AtomicReference
import org.junit.Test
import com.sirolf2009.objectchain.example.common.model.ClaimUsername

class TestChat {

	@Test
	def void test() {
		val AtomicReference<ChatNode> node1 = new AtomicReference()
		val AtomicReference<ChatNode> node2 = new AtomicReference()
		val AtomicReference<ChatMiner> miner = new AtomicReference()
		new Thread([
			new ChatTracker(2012).start()
		], "Tracker").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(#["localhost"], 4567, Keys.generateAssymetricPair()) => [
				node1.set(it)
				start()
			]
		], "Node1").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(#["localhost"], 4568, Keys.generateAssymetricPair()) => [
				node2.set(it)
				start()
			]
		], "Node2").start()
		Thread.sleep(1000)
		new Thread([
			new ChatMiner(#["localhost"], 4569, Keys.generateAssymetricPair()) => [
				miner.set(it)
				start()
			]
		], "Miner").start()

		node1.say("Hello World!")
		node2.say("Yoo check this out")
		node2.claim("sirolf2009")
		node2.say("What do you think?")
		node1.claim("The entire youtube comment section")
		node1.say("OMG rolf lmaosauce XDDDDDDD")

		Thread.sleep(10000)

		miner.get().blockchain.blocks.forEach [
			println(it.toString(node1.get().kryo))
		]
		println()
		miner.get().floatingMutations.forEach [
			println(it.toString(node1.get().kryo))
		]
	}

	def say(AtomicReference<ChatNode> node, String msg) {
		node.get().submitMutation(new Message() => [
			message = msg
		])
		Thread.sleep(2000)
	}

	def claim(AtomicReference<ChatNode> node, String user) {
		node.get().submitMutation(new ClaimUsername() => [
			username = user
		])
		Thread.sleep(2000)
	}

}
