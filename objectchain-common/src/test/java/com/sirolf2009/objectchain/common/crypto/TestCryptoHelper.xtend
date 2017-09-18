package com.sirolf2009.objectchain.common.crypto

import junit.framework.Assert
import org.junit.Test

class TestCryptoHelper {
	
	@Test
	def void testSignatureString() {
		val msg = "Hello World"
		val keys = Keys.generateAssymetricPair()
		val sign = CryptoHelper.sign(msg, keys.private)
		Assert.assertTrue(CryptoHelper.verify(msg, sign, keys.public))
	}
	
	@Test
	def void testFaultySignatureString() {
		val msg = "Hello World"
		val expected = "I love you Bob, xxx Alice"
		val keys = Keys.generateAssymetricPair()
		val sign = CryptoHelper.sign(msg, keys.private)
		Assert.assertFalse(CryptoHelper.verify(expected, sign, keys.public)) //Poor bob :(
	}
	
	@Test
	def void testSignature() {
		val msg = #[0 as byte, 1 as byte, 2 as byte, 3 as byte]
		val keys = Keys.generateAssymetricPair()
		val sign = CryptoHelper.sign(msg, keys.private)
		Assert.assertTrue(CryptoHelper.verify(msg, sign, keys.public))
	}
	
	@Test
	def void testFaultySignature() {
		val msg = #[0 as byte, 1 as byte, 2 as byte, 3 as byte]
		val expected = #[4 as byte, 5 as byte, 6 as byte, 7 as byte]
		val keys = Keys.generateAssymetricPair()
		val sign = CryptoHelper.sign(msg, keys.private)
		Assert.assertFalse(CryptoHelper.verify(expected, sign, keys.public))
	}
	
	@Test
	def void testSecretRoundTripString() {
		val msg = "Hello World"
		val secret = Keys.generateSecretKey()
		val encrypted = CryptoHelper.encrypt(msg, secret)
		val decrypted = CryptoHelper.decrypt(encrypted, secret)
		Assert.assertEquals(msg, decrypted)
	}
	
	@Test
	def void testSecretRoundTripBytes() { 
		val msg = #[0 as byte, 1 as byte, 2 as byte, 3 as byte]
		val secret = Keys.generateSecretKey()
		val encrypted = CryptoHelper.encrypt(msg, secret)
		val decrypted = CryptoHelper.decrypt(encrypted, secret)
		Assert.assertEquals(msg, decrypted.toList())
	}
	
	@Test
	def void testAssymetricRoundTripString() {
		val msg = "Hello World"
		val keys = Keys.generateAssymetricPair()
		val encrypted = CryptoHelper.encrypt(msg, keys.public)
		val decrypted = CryptoHelper.decrypt(encrypted, keys.private)
		Assert.assertEquals(msg, decrypted)
	}
	
	@Test
	def void testAssymetricRoundTripBytes() {
		val msg = #[0 as byte, 1 as byte, 2 as byte, 3 as byte]
		val keys = Keys.generateAssymetricPair()
		val encrypted = CryptoHelper.encrypt(msg, keys.public)
		val decrypted = CryptoHelper.decrypt(encrypted, keys.private)
		Assert.assertEquals(msg, decrypted.toList())
	}
	
}