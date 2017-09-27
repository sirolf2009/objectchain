package com.sirolf2009.objectchain.example.tests

import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.example.tracker.ChatTracker
import java.math.BigInteger
import java.util.Date
import java.util.concurrent.atomic.AtomicReference
import org.junit.Test
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.network.node.NewBlock

import static extension com.sirolf2009.objectchain.example.tests.Util.*

class TestNewBlock {
	
	@Test
	def void test() {
		val AtomicReference<ChatNode> node1 = new AtomicReference()
		val AtomicReference<ChatNode> node2 = new AtomicReference()
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
		Thread.sleep(3000)
		
		val mutations = #[
			new Mutation(new Message() => [
				message = "Hello World"
			], node1.get().keys),
			new Mutation(new Message() => [
				message = "Are you new here?"
			], node1.get().keys)
		].toSet()
		val newBlockHeader = new BlockHeader(node1.get().blockchain.blocks.last.hash(node1.get().kryo), MerkleTree.merkleTreeMutations(node1.get().kryo, mutations), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 0)
		val newBlock = new Block(newBlockHeader, mutations)
		node1.get().broadcast(new NewBlock() => [
			it.block = newBlock
		])
		Thread.sleep(3000)
		
		node2.printBlockChain()
	}
	
}