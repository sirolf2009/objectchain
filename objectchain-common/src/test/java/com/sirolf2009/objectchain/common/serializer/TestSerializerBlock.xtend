package com.sirolf2009.objectchain.common.serializer

import com.sirolf2009.objectchain.common.model.BlockHeader
import java.math.BigInteger
import java.util.ArrayList
import java.util.Date
import org.junit.Test
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block
import org.junit.Assert
import com.esotericsoftware.kryo.io.Output
import com.esotericsoftware.kryo.io.Input
import java.io.ByteArrayOutputStream

class TestSerializerBlock {
	
	@Test
	def void test() {
		val kryo = new Kryo() => [
			register(BlockHeader, new SerializerBlockHeader())
			register(Block, new SerializerBlock())
		]
		
		val header = new BlockHeader(new ArrayList(), new ArrayList(), new Date(), BigInteger.ONE, 0)
		val block = new Block(header, new ArrayList())
		
		val outBuffer = new ByteArrayOutputStream()
		val out = new Output(outBuffer)
		kryo.writeObject(out, block)
		
		val in = new Input(out.buffer)
		Assert.assertEquals(block, kryo.readObject(in, Block))
	}
	
}