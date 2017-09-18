package com.sirolf2009.objectchain.common.crypto

import java.io.File
import junit.framework.Assert
import org.junit.Test

import static com.sirolf2009.objectchain.common.crypto.TestKeys.*

class TestCryptoHelper {
	
	@Test
	def void generateTestKeys() {
		val pair = Keys.generatePair()
		Keys.writeKeyToFile(pair.private, new File("src/test/resources/alice.private"))
		Keys.writeKeyToFile(pair.public, new File("src/test/resources/alice.public"))
		val pair2 = Keys.generatePair()
		Keys.writeKeyToFile(pair2.private, new File("src/test/resources/bob.private"))
		Keys.writeKeyToFile(pair2.public, new File("src/test/resources/bob.public"))
	}
	
	@Test
	def void testSimpleRoundtrip() {
		val msg = "Hello World"
		val encrypted = CryptoHelper.encrypt(msg, alicePrivate)
		println(encrypted)
		val decrypted = CryptoHelper.decrypt(encrypted, alicePublic)
		Assert.assertEquals(msg, decrypted)
	}
	
}