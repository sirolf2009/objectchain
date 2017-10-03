package com.sirolf2009.objectchain.example.tests

import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.example.tracker.ChatTracker
import com.sirolf2009.objectchain.network.node.NewBlock
import java.math.BigInteger
import java.time.Duration
import java.util.Date
import java.util.TreeSet
import java.util.concurrent.atomic.AtomicReference
import org.junit.Assert
import org.junit.Test
import org.slf4j.LoggerFactory
import com.sirolf2009.objectchain.example.common.model.ChatConfiguration
import org.junit.After

class TestNewBlock {

	val AtomicReference<ChatTracker> tracker = new AtomicReference()
	val AtomicReference<ChatNode> node1 = new AtomicReference()
	val AtomicReference<ChatNode> node2 = new AtomicReference()

	@Test
	def void test() {
		val config = new Configuration(8, Duration.ofMinutes(1), 512, 512, new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), new ChatConfiguration().genesisState)
		new Thread([
			new ChatTracker(2012) => [
				tracker.set(it)
				start()
			]
		], "Tracker").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(LoggerFactory.getLogger("node1"), config, #["localhost"], 4567, Keys.generateAssymetricPair()) => [
				node1.set(it)
				start()
			]
		], "Node1").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(LoggerFactory.getLogger("node2"), config, #["localhost"], 4568, Keys.generateAssymetricPair()) => [
				node2.set(it)
				start()
			]
		], "Node2").start()
		Thread.sleep(3000)

		val mutations = new TreeSet(#[
			new Mutation(new Message() => [
				message = "Hello World"
			], node1.get().keys),
			new Mutation(new Message() => [
				message = "Are you new here?"
			], node1.get().keys)
		])

		val newBlockHeader = node2.get().kryoPool.run[kryo|new BlockHeader(node2.get().blockchain.mainBranch.blocks.last.hash(kryo), MerkleTree.merkleTreeMutations(kryo, mutations), new Date(), node2.get().blockchain.mainBranch.lastBlock.header.target, 0)]
		val newBlock = new Block(newBlockHeader, mutations)
		node2.get().broadcast(new NewBlock() => [
			it.block = newBlock
		])
		Thread.sleep(1000)
		
		Assert.assertEquals(node1.get().blockchain.mainBranch.blocks.size(), 2)
	}

	@After
	def void cleanup() {
		tracker.get()?.close()
		node1.get()?.close()
		node2.get()?.close()
		Thread.sleep(1000) // allow for connections to close
	}

}
