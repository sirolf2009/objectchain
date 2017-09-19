package com.sirolf2009.objectchain.common

import org.junit.Test
import com.sirolf2009.objectchain.common.MerkleTree
import org.junit.Assert

class TestMerkleTree {

	@Test
	def void testBitcoinPizzaTransaction() {
		val transactions = #["bd9075d78e65a98fb054cb33cf0ecf14e3e7f8b3150231df8680919a79ac8fe5", "a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d"]
		println(MerkleTree.merkleTree(transactions))
	}//5c1d2211f598cd6498f42b269fe3ce4a6fdb40eaa638f86a0579c4e63a721b5a
	
	@Test
	def void testOddLeaves() {
		val leaves = #["To do is to be", "To be is to do", "do be do be do"]
		Assert.assertEquals("18b14d1a519510d1c41841f81071c81b71321f51ae1761241d61971221c515e1211f115d1981641c71701521c01371f4", MerkleTree.merkleTree(leaves))
	}

	@Test
	def void testEvenLeaves() {
		val leaves = #["Is it a bird?", "Is it a plane?", "No, it's superman!", "Why do the first two people always get so exited over birds and planes?"]
		Assert.assertEquals("1221a01a21631e41b917e16115214b15413b1c21be1251c91fa1f41b21c91dd1d61d31621cf16112b1d51361f21c612e", MerkleTree.merkleTree(leaves))
	}
	
}