package com.sirolf2009.objectchain.example.tests

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.example.miner.ChatMiner
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.example.tracker.ChatTracker
import java.net.InetSocketAddress
import java.util.concurrent.atomic.AtomicReference
import org.junit.After
import org.junit.Test
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.example.tests.Util.*

class TestChat {

	val AtomicReference<ChatTracker> tracker = new AtomicReference()
	val AtomicReference<ChatNode> node1 = new AtomicReference()
	val AtomicReference<ChatNode> node2 = new AtomicReference()
	val AtomicReference<ChatMiner> miner = new AtomicReference()

	@Test
	def void test() {
		new Thread([
			new ChatTracker(2012) => [
				tracker.set(it)
				start()
			]
		], "Tracker").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(LoggerFactory.getLogger("node1"), #[new InetSocketAddress("localhost", 2012)], 4567, Keys.generateAssymetricPair()) => [
				node1.set(it)
				start()
			]
		], "Node1").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(LoggerFactory.getLogger("node2"), #[new InetSocketAddress("localhost", 2012)], 4568, Keys.generateAssymetricPair()) => [
				node2.set(it)
				start()
			]
		], "Node2").start()
		Thread.sleep(1000)
		new Thread([
			new ChatMiner(LoggerFactory.getLogger("miner"), #[new InetSocketAddress("localhost", 2012)], 4569, Keys.generateAssymetricPair()) => [
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

		miner.get().printBlockChain()
		miner.get().printState()
		node1.get().printState()
	}

	@After
	def void cleanup() {
		tracker.get()?.closeSafe()
		node1.get()?.closeSafe()
		node2.get()?.closeSafe()
		miner.get()?.closeSafe()
		Thread.sleep(4000) // allow for connections to close
	}

}
