package com.sirolf2009.objectchain.common.model

import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.TestKryo
import com.sirolf2009.objectchain.common.crypto.Keys
import java.math.BigInteger
import java.util.Date
import org.junit.Assert
import org.junit.Test

class TestBlock {
	
	@Test
	def void testTarget() {
		val kryo = TestKryo.kryo
		val msg = new Message() => [
			msg = "Hello World"
		]
		val keys = Keys.generateAssymetricPair()
		val transaction = new Transaction(0, msg, keys)

		val easyTarget = new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16)
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 0).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 1).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 2).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 3).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 4).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 5).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 6).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 7).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 8).isBelowTarget(kryo))
		Assert.assertTrue(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), easyTarget, 9).isBelowTarget(kryo))

		val impossibleTarget = new BigInteger("0000000000000000000000000000000000000000000000000000000000000000", 16)
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 0).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 1).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 2).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 3).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 4).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 5).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 6).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 7).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 8).isBelowTarget(kryo))
		Assert.assertFalse(new BlockHeader(#[], MerkleTree.merkleTreeTransactions(kryo, #[transaction]), new Date(), impossibleTarget, 9).isBelowTarget(kryo))
	}
	
}