package com.sirolf2009.objectchain.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import java.math.BigInteger
import java.util.Date
import java.util.TreeSet
import org.junit.Assert
import org.junit.Test

class TestMerkleTree {
	
	@Test
	def void testMutations() {
		val kryo = new Kryo()
		KryoRegistryCommon.register(kryo, null)
		val keys = Keys.generateAssymetricPair()
		val mutation1 = new Mutation("Hello World! 1", kryo, keys)
		val mutation2 = new Mutation("Hello World! 2", kryo, keys)
		
		val mutation1Hash = mutation1.hash(kryo)
		
		Assert.assertEquals(mutation1Hash, MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1])))
		Assert.assertEquals(mutation1Hash, MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1])))
		
		Assert.assertEquals(MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1])), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1])))
		Assert.assertEquals(MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1, mutation2])), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation2, mutation1])))
		Assert.assertEquals(mutation1Hash, MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1])))
		
		val genesis = new Block(new BlockHeader(newArrayOfSize(0), newArrayOfSize(0), new Date(), BigInteger.ONE, 0), new TreeSet())
		val block = new Block(new BlockHeader(genesis.hash(kryo), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1])), new Date(), BigInteger.ONE, 1), new TreeSet(#[mutation1]))
		Assert.assertEquals(mutation1Hash, block.header.merkleRoot)
	}

	@Test
	def void testBitcoinPizzaTransaction() {
		val transactions = #["bd9075d78e65a98fb054cb33cf0ecf14e3e7f8b3150231df8680919a79ac8fe5", "a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d"]
		Assert.assertEquals("5c1d2211f598cd6498f42b269fe3ce4a6fdb40eaa638f86a0579c4e63a721b5a", MerkleTree.merkleTreeHex(transactions))
	}
	
}