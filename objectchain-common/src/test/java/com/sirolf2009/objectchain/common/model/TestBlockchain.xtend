package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.KryoRegistryCommon
import java.math.BigInteger
import java.util.ArrayList
import java.util.Arrays
import java.util.Date
import java.util.TreeSet
import junit.framework.Assert
import org.junit.Test

class TestBlockchain {

	@Test
	def void testBranching() {
		val kryo = new Kryo()
		KryoRegistryCommon.register(kryo)
		val blockchain = new BlockChain()
		val genesis = new Block(new BlockHeader(newArrayOfSize(0), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 0), new TreeSet())
		blockchain.mainBranch = new Branch(genesis, new ArrayList(Arrays.asList(genesis)), new ArrayList())
		
		val main1 = new Block(new BlockHeader(genesis.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 1), new TreeSet())
		val main2 = new Block(new BlockHeader(main1.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 2), new TreeSet())
		val main3 = new Block(new BlockHeader(main2.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 3), new TreeSet())
		blockchain.mainBranch.blocks.addAll(main1, main2, main3)
		Assert.assertEquals(4, blockchain.mainBranch.blocks.size())
		
		val side1 = new Block(new BlockHeader(genesis.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 4), new TreeSet())
		val side2 = new Block(new BlockHeader(side1.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 5), new TreeSet())
		val branch = new Branch(genesis, new ArrayList(Arrays.asList(genesis, side1, side2)), new ArrayList())
		blockchain.sideBranches.add(branch)
		Assert.assertEquals(3, blockchain.totalBranchLength(branch))
		Assert.assertFalse(blockchain.isBranchLonger(branch))
		
		val side3 = new Block(new BlockHeader(side2.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 6), new TreeSet())
		branch.blocks.add(side3)
		Assert.assertEquals(4, blockchain.totalBranchLength(branch))
		Assert.assertFalse(blockchain.isBranchLonger(branch))
		
		val side4 = new Block(new BlockHeader(side3.hash(kryo), newArrayOfSize(0), new Date(), new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), 7), new TreeSet())
		branch.blocks.add(side4)
		Assert.assertEquals(5, blockchain.totalBranchLength(branch))
		Assert.assertTrue(blockchain.isBranchLonger(branch))
		
		blockchain.promoteBranch(branch)
		
		Assert.assertEquals(5, blockchain.mainBranch.size())
		Assert.assertEquals(side4.toString(kryo), blockchain.mainBranch.blocks.last.toString(kryo))
		Assert.assertEquals(main3.toString(kryo), blockchain.sideBranches.get(0).blocks.last.toString(kryo))
	}

}
