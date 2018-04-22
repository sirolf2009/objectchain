package com.sirolf2009.objectchain.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockChain
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Branch
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.TestState
import java.math.BigInteger
import java.time.Duration
import java.util.ArrayList
import java.util.Arrays
import java.util.Date
import java.util.TreeSet
import org.junit.Test
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.common.crypto.Keys
import java.io.File
import junit.framework.Assert
import com.sirolf2009.objectchain.common.model.Hash

class TestBlockchainPersistence {

	val target = new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16).add(BigInteger.ONE) // max possible hash + 1, i.e. hit always

	@Test
	def void testPersistence() {
		val kryo = new Kryo()
		val configuration = new Configuration(10000, Duration.ofMinutes(1), 1000, 1024, target, new TestState(0))
		KryoRegistryCommon.register(kryo, configuration)
		val keys = Keys.generateAssymetricPair()
		val blockchain = new BlockChain() => [
			val genesis = new Block(new BlockHeader(new Hash(#[]), new Hash(new ArrayList()), new Date(), target, 0), new TreeSet())
			mainBranch = new Branch(genesis, new ArrayList(Arrays.asList(genesis)), new ArrayList(Arrays.asList(new TestState(0)))) => [
				val mutation1 = new Mutation("1", kryo, keys)
				val block1 = new Block(new BlockHeader(genesis.hash(kryo), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1])), new Date(), target, 0), new TreeSet(Arrays.asList(mutation1)))
				addBlock(kryo, configuration, block1)
				val mutation2 = new Mutation("2", kryo, keys)
				val mutation3 = new Mutation("3", kryo, keys)
				val block2 = new Block(new BlockHeader(block1.hash(kryo), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation2, mutation3])), new Date(), target, 0), new TreeSet(Arrays.asList(mutation2, mutation3)))
				addBlock(kryo, configuration, block2)
				val mutation4 = new Mutation("4", kryo, keys)
				val mutation5 = new Mutation("5", kryo, keys)
				val mutation6 = new Mutation("6", kryo, keys)
				val mutation7 = new Mutation("7", kryo, keys)
				val block3 = new Block(new BlockHeader(block2.hash(kryo), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation4, mutation5, mutation6, mutation7])), new Date(), target, 0), new TreeSet(Arrays.asList(mutation4, mutation5, mutation6, mutation7)))
				addBlock(kryo, configuration, block3)
			]
		]

		BlockchainPersistence.save(kryo, blockchain, new File("src/test/resources/TestBlockchainPersistence.blockchain"))
		val loaded = BlockchainPersistence.load(kryo, configuration, new File("src/test/resources/TestBlockchainPersistence.blockchain"))
		Assert.assertEquals(blockchain.mainBranch.hash(kryo), loaded.mainBranch.hash(kryo))
	}

	@Test
	def void testPersistenceBranches() {
		val kryo = new Kryo()
		val configuration = new Configuration(10000, Duration.ofMinutes(1), 1000, 1024, target, new TestState(0))
		KryoRegistryCommon.register(kryo, configuration)
		val keys = Keys.generateAssymetricPair()

		val genesis = new Block(new BlockHeader(new Hash(#[]), new Hash(new ArrayList()), new Date(), target, 0), new TreeSet())
		val mutation1 = new Mutation("1", kryo, keys)
		val block1 = new Block(new BlockHeader(genesis.hash(kryo), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation1])), new Date(), target, 0), new TreeSet(Arrays.asList(mutation1)))
		val mutation2 = new Mutation("2", kryo, keys)
		val mutation3 = new Mutation("3", kryo, keys)
		val block2 = new Block(new BlockHeader(block1.hash(kryo), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation2, mutation3])), new Date(), target, 0), new TreeSet(Arrays.asList(mutation2, mutation3)))
		val mutation4 = new Mutation("4", kryo, keys)
		val mutation5 = new Mutation("5", kryo, keys)
		val mutation6 = new Mutation("6", kryo, keys)
		val mutation7 = new Mutation("7", kryo, keys)
		val block3 = new Block(new BlockHeader(block2.hash(kryo), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation4, mutation5, mutation6, mutation7])), new Date(), target, 0), new TreeSet(Arrays.asList(mutation4, mutation5, mutation6, mutation7)))
		val block3branch = new Block(new BlockHeader(block2.hash(kryo), MerkleTree.merkleTreeMutations(kryo, new TreeSet(#[mutation4, mutation5])), new Date(), target, 0), new TreeSet(Arrays.asList(mutation4, mutation5)))

		val blockchain = new BlockChain() => [
			mainBranch = new Branch(genesis, new ArrayList(Arrays.asList(genesis)), new ArrayList(Arrays.asList(new TestState(0)))) => [
				addBlock(kryo, configuration, block1)
				addBlock(kryo, configuration, block2)
				addBlock(kryo, configuration, block3)
				
			]
			branchOff(kryo, block3branch)
		]

		BlockchainPersistence.save(kryo, blockchain, new File("src/test/resources/TestBlockchainPersistence.blockchain"))
		val loaded = BlockchainPersistence.load(kryo, configuration, new File("src/test/resources/TestBlockchainPersistence.blockchain"))
		Assert.assertEquals(blockchain.mainBranch.hash(kryo), loaded.mainBranch.hash(kryo))
		Assert.assertEquals(blockchain.sideBranches.get(0).hash(kryo), loaded.sideBranches.get(0).hash(kryo))
	}

}
