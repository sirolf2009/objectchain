package com.sirolf2009.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import java.math.BigInteger
import java.util.TreeSet
import junit.framework.Assert
import org.junit.Test
import org.objectchain.mining.model.BlockHeaderMutable
import org.objectchain.mining.model.BlockMutable

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class TestBlockMutable {
	
	@Test
	def void testHashMutableImmutable() {
		val keys = Keys.generateAssymetricPair()
		val blockMutable = new BlockMutable(new BlockHeaderMutable(#[1 as byte, 2 as byte, 3 as byte], BigInteger.TEN), new TreeSet(#[
			new Mutation("Hello World!", keys)
		]))
		
		val kryo = new Kryo()
		kryo.register(Block)
		kryo.register(BlockHeader)
		kryo.register(BlockMutable)
		kryo.register(BlockHeaderMutable)
		println(blockMutable.header.hash(kryo).toHexString())
		println(blockMutable.immutable().header.hash(kryo).toHexString())
		Assert.assertEquals(blockMutable.header.hash(kryo), blockMutable.immutable().header.hash(kryo))
		Assert.assertEquals(blockMutable.header.isBelowTarget(kryo), blockMutable.immutable().header.isBelowTarget(kryo))
	}
	
}