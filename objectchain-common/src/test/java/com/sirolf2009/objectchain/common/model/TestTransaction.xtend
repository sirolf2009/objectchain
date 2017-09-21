package com.sirolf2009.objectchain.common.model

import com.sirolf2009.objectchain.common.crypto.Keys
import org.junit.Assert
import org.junit.Test

class TestTransaction {

	@Test
	def void testVerification() {
		val msg = new Message() => [
			msg = "Hello World"
		]
		val keys = Keys.generateAssymetricPair()
		val transaction = new Transaction(0, msg, keys)
		Assert.assertTrue(transaction.verifySignature())

		val eve = Keys.generateAssymetricPair()
		val maliciousTransaction = new Transaction(0, msg, eve.private, keys.public)
		Assert.assertFalse(maliciousTransaction.verifySignature())
	}

}
