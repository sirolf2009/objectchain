package com.sirolf2009.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.KryoRegistrationNode
import java.math.BigInteger
import java.time.Duration
import java.util.TreeSet
import junit.framework.Assert
import org.junit.Test

import com.sirolf2009.objectchain.common.model.Hash

class TestBlockMutable {
	
	@Test
	def void testMerkleTree() {
		val keys = Keys.generateAssymetricPair()
		val kryo = new Kryo()
		KryoRegistrationNode.register(kryo, configuration)
		
		val blockMutable = new BlockMutable(new BlockHeaderMutable(new Hash(#[1 as byte, 2 as byte, 3 as byte]), BigInteger.TEN), new TreeSet())
		Assert.assertNull(null, blockMutable.header.merkleRoot)
		blockMutable.addMutation(kryo, configuration, new Mutation("Hello World!", kryo, keys))
		Assert.assertNotNull(null, blockMutable.header.merkleRoot)
	}
	
	@Test
	def void testHashMutableImmutable() {
		val keys = Keys.generateAssymetricPair()
		val kryo = new Kryo()
		KryoRegistrationNode.register(kryo, configuration)
		
		val blockMutable = new BlockMutable(new BlockHeaderMutable(new Hash(#[1 as byte, 2 as byte, 3 as byte]), BigInteger.TEN), new TreeSet())
		blockMutable.addMutation(kryo, configuration, new Mutation("Hello World!", kryo, keys))
		
		println(blockMutable.header.hash(kryo))
		println(blockMutable.immutable().header.hash(kryo))
		Assert.assertEquals(blockMutable.header.hash(kryo), blockMutable.immutable().header.hash(kryo))
		Assert.assertEquals(blockMutable.header.isBelowTarget(kryo), blockMutable.immutable().header.isBelowTarget(kryo))
	}
	
	def configuration() {
		return new Configuration(4, Duration.ofSeconds(1), 1, 1024, new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), new TestState(1))
	}
	
}