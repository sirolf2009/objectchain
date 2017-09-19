package com.sirolf2009.objectchain.common.crypto

import org.junit.Test
import org.junit.Assert

class TestHashing {

	@Test
	def void testBlock125552() {
		val hex = "01000000" + "81cd02ab7e569e8bcd9317e2fe99f2de44d49ab2b8851ba4a308000000000000" + "e320b6c2fffc8d750423db8b1eb942ae710e951ed797f7affc8892b0f1fc122b" + "c7f5d74d" + "f2b9441a" + "42a14695"
		println(Hashing.hash(hex))
	}

	@Test
	def void hashString() {
		val msg = "Hello World"
		Assert.assertEquals("1a51911a61d410b1f412014014a1011171331cf1b71b11901d612c1651bf10b1cd1a312b1571b21771d91ad19f11416e", Hashing.hash(msg))
	}

}
