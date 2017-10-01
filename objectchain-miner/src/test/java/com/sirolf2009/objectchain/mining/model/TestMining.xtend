package com.sirolf2009.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Branch
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.KryoRegistrationNode
import java.math.BigInteger
import java.time.Duration
import java.util.ArrayList
import java.util.Date
import java.util.TreeSet
import org.junit.Assert
import org.junit.Test
import com.sirolf2009.objectchain.mining.model.BlockHeaderMutable
import com.sirolf2009.objectchain.mining.model.BlockMutable

class TestMining {

	@Test
	def void test() {
		val target = new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16).add(BigInteger.ONE) // max possible hash + 1, i.e. hit always
		val genesis = new Block(new BlockHeader(#[], #[], new Date(), target, 0), new TreeSet())
		val branch = new Branch(genesis, new ArrayList(#[genesis]), new ArrayList(#[new TestState(1)]))
		val keys = Keys.generateAssymetricPair()

		val kryo = new Kryo()
		KryoRegistrationNode.register(kryo)

		val pendingBlock = new BlockMutable(new BlockHeaderMutable(genesis.header.hash(kryo), genesis.header.target), new TreeSet()) => [
			header.time = new Date()
		]
		pendingBlock.addMutation(kryo, configuration, new Mutation("Hello World!", keys))
		Assert.assertTrue(pendingBlock.header.isBelowTarget(kryo))
		branch.addBlock(kryo, configuration, pendingBlock.immutable())
	}
	
	def configuration() {
		return new Configuration(4, Duration.ofSeconds(1), 1, 1024, new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16))
	}

}
