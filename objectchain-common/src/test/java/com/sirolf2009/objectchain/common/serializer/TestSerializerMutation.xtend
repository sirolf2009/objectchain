package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.KryoRegistryCommon
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Mutation
import java.io.ByteArrayOutputStream
import org.junit.Assert
import org.junit.Test

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class TestSerializerMutation {
	
	@Test
	def void test() {
		val kryo = new Kryo()
		KryoRegistryCommon.register(kryo, null)
		
		val mutation = new Mutation("Hello World", kryo, Keys.generateAssymetricPair())
		
		val outBuffer = new ByteArrayOutputStream()
		val out = new Output(outBuffer)
		kryo.writeObject(out, mutation)
		
		val in = new Input(out.buffer)
		Assert.assertEquals(mutation, kryo.readObject(in, Mutation))
	}
	
	@Test
	def void testHash() {
		val kryo = new Kryo()
		KryoRegistryCommon.register(kryo, null)
		val keys = Keys.generateAssymetricPair()
		
		val mutation1 = new Mutation("Hello World", kryo, keys)
		val mutation2 = new Mutation("Hello World", kryo, keys)
		
		Assert.assertEquals(mutation1.getBytes(kryo).toHexString(), mutation2.getBytes(kryo).toHexString())
	}
	
}