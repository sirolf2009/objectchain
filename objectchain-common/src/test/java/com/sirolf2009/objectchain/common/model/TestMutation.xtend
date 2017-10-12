package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.KryoRegistryCommon
import com.sirolf2009.objectchain.common.crypto.Keys
import org.junit.Assert
import org.junit.Test

class TestMutation {

	@Test
	def void testVerification() {
		val kryo = new Kryo()
		KryoRegistryCommon.register(kryo, null)
		val msg = new Message() => [
			msg = "Hello World"
		]
		val keys = Keys.generateAssymetricPair()
		val mutation = new Mutation(msg, kryo, keys)
		Assert.assertTrue(mutation.verifySignature(kryo))

		val eve = Keys.generateAssymetricPair()
		val maliciousMutation = new Mutation(msg, kryo, eve.private, keys.public)
		Assert.assertFalse(maliciousMutation.verifySignature(kryo))
	}

}
