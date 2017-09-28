package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.KryoRegistryCommon
import com.sirolf2009.objectchain.common.crypto.Keys
import java.math.BigInteger
import java.time.Duration
import java.util.ArrayList
import java.util.Arrays
import java.util.Date
import java.util.TreeSet
import org.junit.Assert
import org.junit.Test
import com.sirolf2009.objectchain.common.MerkleTree

class TestBranch {

	@Test
	def void testExpansion() {
		val kryo = new Kryo()
		KryoRegistryCommon.register(kryo)
		val keys = Keys.generateAssymetricPair()
		val genesis = new Block(new BlockHeader(newArrayOfSize(0), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 0), new TreeSet())
		val branch = new Branch(genesis, new ArrayList(Arrays.asList(genesis)))
		val configuration = new Configuration(4, Duration.ofMillis(1), 10, 1024)

		val mutation1 = new Mutation("Hello World! 1", keys)
		val mutation2 = new Mutation("Hello World! 2", keys)
		val mutation3 = new Mutation("Hello World! 3", keys)

		val block1 = new Block(new BlockHeader(genesis.hash(kryo), MerkleTree.merkleTreeMutations(kryo, #[mutation1]), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 1), new TreeSet(#[mutation1]))
		val block2 = new Block(new BlockHeader(block1.hash(kryo), MerkleTree.merkleTreeMutations(kryo, #[mutation2]), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 2), new TreeSet(#[mutation2]))
		val block3 = new Block(new BlockHeader(block2.hash(kryo), MerkleTree.merkleTreeMutations(kryo, #[mutation3]), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 3), new TreeSet(#[mutation3]))

		branch.addBlock(kryo, configuration, block1)
		branch.addBlock(kryo, configuration, block2)
		branch.addBlock(kryo, configuration, block3)
	}

	@Test
	def void testTarget() {
		val currentTarget = BigInteger.valueOf(2)
		val blockDuration = Duration.ofMinutes(10).toMillis()
		val retargetDuration = Duration.ofDays(7).toMillis()
		Assert.assertEquals(BigInteger.valueOf(4), Branch.getNewTarget(currentTarget, 2016, blockDuration, retargetDuration))

		val kryo = new Kryo()
		KryoRegistryCommon.register(kryo)
		val genesis = new Block(new BlockHeader(newArrayOfSize(0), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 0), new TreeSet())
		val branch = new Branch(genesis, new ArrayList(Arrays.asList(genesis)))

		Assert.assertFalse(branch.shouldRetarget(5))
		Assert.assertFalse(branch.shouldRetarget(4))
		Assert.assertFalse(branch.shouldRetarget(3))

		val main1 = new Block(new BlockHeader(genesis.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 1), new TreeSet())
		val main2 = new Block(new BlockHeader(main1.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 2), new TreeSet())
		val main3 = new Block(new BlockHeader(main2.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 3), new TreeSet())
		branch.blocks.addAll(main1, main2, main3)

		Assert.assertFalse(branch.shouldRetarget(5))
		Assert.assertTrue(branch.shouldRetarget(4))
		Assert.assertFalse(branch.shouldRetarget(3))
	}

}
