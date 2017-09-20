package com.sirolf2009.objectchain.common.crypto

import org.junit.Test
import org.junit.Assert

class TestHashing {

	@Test
	def void testBlock125552() {
		val hex = "01000000" + "81cd02ab7e569e8bcd9317e2fe99f2de44d49ab2b8851ba4a308000000000000" + "e320b6c2fffc8d750423db8b1eb942ae710e951ed797f7affc8892b0f1fc122b" + "c7f5d74d" + "f2b9441a" + "42a14695"
		val hashed = Hashing.doubleHash(Hashing.toByteArray(hex))
		Assert.assertEquals("1dbd981fe6985776b644b173a4d0385ddc1aa2a829688d1e0000000000000000", Hashing.toHexString(hashed))
		Assert.assertEquals("00000000000000001e8d6829a8a21adc5d38d0a473b144b6765798e61f98bd1d", Hashing.toHexString(hashed.reverseView()))
	}
	
	@Test
	def void roundTripHex() {
		val msg = "Hello World"
		val hex = Hashing.toHexString(msg.getBytes("UTF-8"))
		val newMsg = new String(Hashing.toByteArray(hex), "UTF-8")
		Assert.assertEquals(msg, newMsg)
	}
	
	@Test
	def void doubleHash() {
		val left = "aa"
		val right = "bb"
		Assert.assertEquals("f15813fa4b03e4569a24340601ee233a4f5fde24a1a51e094409f6ae3a6e9233", Hashing.doubleHashHex(left, right))
	}

	@Test
	def void hashString() {
		val msg = "Hello World"
		Assert.assertEquals("a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e", Hashing.hash(msg))
	}
	
}