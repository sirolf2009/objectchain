package com.sirolf2009.objectchain.common.crypto

import org.junit.Test
import org.junit.Assert

class TestEncryption {

	@Test
	def void testRoundTripString() {
		val msg = "Hello World"
		val keys = Keys.generateAssymetricPair()
		val encrypted = Encryption.encryptMessage(msg, keys.public)
		val decrypted = Decryption.decryptMessage(encrypted, keys.private)
		Assert.assertEquals(msg, decrypted)
	}

	@Test
	def void testRoundTripBytes() {
		val msg = #[0 as byte, 1 as byte, 2 as byte, 3 as byte]
		val keys = Keys.generateAssymetricPair()
		val encrypted = Encryption.encryptPayload(msg, keys.public)
		val decrypted = Decryption.decryptPayload(encrypted, keys.private)
		Assert.assertEquals(msg, decrypted.toList())
	}
	
}