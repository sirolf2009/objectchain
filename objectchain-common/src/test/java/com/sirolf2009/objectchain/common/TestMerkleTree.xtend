package com.sirolf2009.objectchain.common

import org.junit.Test
import com.sirolf2009.objectchain.common.MerkleTree
import org.junit.Assert

class TestMerkleTree {

	@Test
	def void testBitcoinPizzaTransaction() {
		val transactions = #["bd9075d78e65a98fb054cb33cf0ecf14e3e7f8b3150231df8680919a79ac8fe5", "a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d"]
		Assert.assertEquals("5c1d2211f598cd6498f42b269fe3ce4a6fdb40eaa638f86a0579c4e63a721b5a", MerkleTree.merkleTreeHex(transactions))
	}
	
}