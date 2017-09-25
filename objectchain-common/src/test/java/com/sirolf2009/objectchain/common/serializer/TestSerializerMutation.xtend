package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Mutation
import java.io.ByteArrayOutputStream
import org.junit.Assert
import org.junit.Test

class TestSerializerMutation {
	
	@Test
	def void test() {
		val kryo = new Kryo() => [
			register(Mutation, new SerializerMutation())
		]
		
		val mutation = new Mutation(0, "Hello World", Keys.generateAssymetricPair())
		
		val outBuffer = new ByteArrayOutputStream()
		val out = new Output(outBuffer)
		kryo.writeObject(out, mutation)
		
		val in = new Input(out.buffer)
		Assert.assertEquals(mutation, kryo.readObject(in, Mutation))
	}
	
}