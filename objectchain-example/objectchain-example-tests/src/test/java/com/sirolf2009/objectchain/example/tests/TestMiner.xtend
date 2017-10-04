package com.sirolf2009.objectchain.example.tests

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.example.miner.ChatMiner
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.example.tracker.ChatTracker
import java.net.InetSocketAddress
import java.util.concurrent.atomic.AtomicReference
import org.junit.After
import org.junit.Assert
import org.junit.Test
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.example.tests.Util.*

class TestMiner {

	val AtomicReference<ChatTracker> tracker = new AtomicReference()
	val AtomicReference<ChatNode> node = new AtomicReference()
	val AtomicReference<ChatMiner> miner = new AtomicReference()

	@Test
	def void testSingle() {
		new Thread([
			new ChatTracker(2012) => [
				tracker.set(it)
				start()
			]
		], "Tracker").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(#[new InetSocketAddress("localhost", 2012)], 4567, Keys.generateAssymetricPair()) => [
				node.set(it)
				start()
			]
		], "Node1").start()
		Thread.sleep(1000)
		new Thread([
			new ChatMiner(#[new InetSocketAddress("localhost", 2012)], 4569, Keys.generateAssymetricPair()) => [
				miner.set(it)
				start()
			]
		], "Miner").start()

		node.say("Hello World!")

		Thread.sleep(10000)

		tracker.get().close()
		node.get().close()
		miner.get().close()
		Thread.sleep(1000) // allow for connections to close
		Assert.assertEquals(node.get().blockchain, miner.get().blockchain)
	}

	@Test
	def void testMultiple() {
		new Thread([
			new ChatTracker(2012) => [
				tracker.set(it)
				start()
			]
		], "Tracker").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(LoggerFactory.getLogger("node1"), #[new InetSocketAddress("localhost", 2012)], 4567, Keys.generateAssymetricPair()) => [
				node.set(it)
				start()
			]
		], "Node1").start()
		Thread.sleep(1000)
		new Thread([
			new ChatMiner(LoggerFactory.getLogger("miner"), #[new InetSocketAddress("localhost", 2012)], 4569, Keys.generateAssymetricPair()) => [
				miner.set(it)
				start()
			]
		], "Miner").start()

		println("\n\n")
		node.say("Hello World! 0", 0)
		Thread.sleep(5000)
		println("\n\n")
		node.say("Hello World! 1", 0)
		node.say("Hello World! 2", 0)
		Thread.sleep(5000)
		println("\n\n")
		node.say("Hello World! 3", 0)
		node.say("Hello World! 4", 0)
		node.say("Hello World! 5", 0)
		Thread.sleep(5000)
		println("\n\n")
		node.say("Hello World! 4", 0)
		node.say("Hello World! 5", 0)
		node.say("Hello World! 6", 0)
		node.say("Hello World! 7", 0)
		node.say("Hello World! 8", 0)
		node.say("Hello World! 9", 0)

		Thread.sleep(10000)
		
		Assert.assertEquals(node.get().blockchain, miner.get().blockchain)
	}

	@After
	def void cleanup() {
		tracker.get()?.closeSafe()
		node.get()?.closeSafe()
		miner.get()?.closeSafe()
		Thread.sleep(4000) // allow for connections to close
	}

}
