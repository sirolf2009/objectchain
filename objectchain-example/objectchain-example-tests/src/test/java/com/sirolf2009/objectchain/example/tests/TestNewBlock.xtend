package com.sirolf2009.objectchain.example.tests

import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.example.tracker.ChatTracker
import com.sirolf2009.objectchain.network.node.NewBlock
import java.math.BigInteger
import java.util.Date
import java.util.TreeSet
import java.util.concurrent.atomic.AtomicReference
import org.junit.Assert
import org.junit.Test
import org.slf4j.LoggerFactory

class TestNewBlock {
	
	@Test
	def void test() {
		val AtomicReference<ChatTracker> tracker = new AtomicReference()
		val AtomicReference<ChatNode> node1 = new AtomicReference()
		val AtomicReference<ChatNode> node2 = new AtomicReference()
		new Thread([
			new ChatTracker(2012) => [
				tracker.set(it)
				start()
			]
		], "Tracker").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(LoggerFactory.getLogger("node1"), #["localhost"], 4567, Keys.generateAssymetricPair()) => [
				node1.set(it)
				start()
			]
		], "Node1").start()
		Thread.sleep(1000)
		new Thread([
			new ChatNode(LoggerFactory.getLogger("node2"), #["localhost"], 4568, Keys.generateAssymetricPair()) => [
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
		
		val newBlockHeader = new BlockHeader(node1.get().blockchain.blocks.last.hash(node2.get().kryo), MerkleTree.merkleTreeMutations(node2.get().kryo, mutations), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 0)
		val newBlock = new Block(newBlockHeader, mutations)
		node2.get().broadcast(new NewBlock() => [
			it.block = newBlock
		])
		Thread.sleep(1000)
		
		Assert.assertEquals(node1.get().blockchain.blocks.size(), 2)
		
		tracker.get().close()
		node1.get().close()
		node2.get().close()
		Thread.sleep(1000) //allow for connections to close
	}
	
}