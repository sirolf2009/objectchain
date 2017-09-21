package com.sirolf2009.objectchain.common.model

import com.sirolf2009.objectchain.common.crypto.Keys
import org.junit.Assert
import org.junit.Test

class TestMutation {

	@Test
	def void testVerification() {
		val msg = new Message() => [
			msg = "Hello World"
		]
		val keys = Keys.generateAssymetricPair()
		val mutation = new Mutation(0, msg, keys)
		Assert.assertTrue(mutation.verifySignature())

		val eve = Keys.generateAssymetricPair()
		val maliciousMutation = new Mutation(0, msg, eve.private, keys.public)
		Assert.assertFalse(maliciousMutation.verifySignature())
	}

}
