package com.sirolf2009.objectchain.common.model

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.crypto.Hashing
import com.sirolf2009.objectchain.common.crypto.Keys
import java.math.BigInteger
import java.util.Date
import org.junit.Assert
import org.junit.Test

class TestBlock {
	
	@Test
	def void testTarget() {
		val gson = new Gson()
		val msg = '''
		{
			"msg": "Hello World"
		}'''
		val object = gson.fromJson(msg, JsonObject)
		val keys = Keys.generateAssymetricPair()
		val transaction = new Transaction(0, object, keys)

		val easyTarget = new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16)
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 0).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 1).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 2).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 3).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 4).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 5).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 6).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 7).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 8).isBelowTarget())
		Assert.assertTrue(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), easyTarget, 9).isBelowTarget())

		val impossibleTarget = new BigInteger("0000000000000000000000000000000000000000000000000000000000000000", 16)
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 0).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 1).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 2).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 3).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 4).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 5).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 6).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 7).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 8).isBelowTarget())
		Assert.assertFalse(new BlockHeader(#[], Hashing.toByteArray(MerkleTree.merkleTreeTransactions(#[transaction])), new Date(), impossibleTarget, 9).isBelowTarget())
	}
	
}