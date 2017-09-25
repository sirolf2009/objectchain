package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import java.io.ByteArrayOutputStream
import java.math.BigInteger
import java.util.ArrayList
import java.util.Date
import java.util.TreeSet
import org.junit.Assert
import org.junit.Test

class TestSerializerBlock {
	
	@Test
	def void test() {
		val kryo = new Kryo() => [
			register(BlockHeader, new SerializerBlockHeader())
			register(Block, new SerializerBlock())
		]
		
		val header = new BlockHeader(new ArrayList(), new ArrayList(), new Date(), BigInteger.ONE, 0)
		val block = new Block(header, new TreeSet())
		
		val outBuffer = new ByteArrayOutputStream()
		val out = new Output(outBuffer)
		kryo.writeObject(out, block)
		
		val in = new Input(out.buffer)
		Assert.assertEquals(block, kryo.readObject(in, Block))
	}
	
}