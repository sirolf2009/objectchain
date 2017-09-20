package com.sirolf2009.objectchain.common.model

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.sirolf2009.objectchain.common.crypto.Keys
import org.junit.Assert
import org.junit.Test

class TestTransaction {
	
	@Test
	def void testVerification() {
		val gson = new Gson()
		val msg = '''
		{
			"msg": "Hello World"
		}'''
		val object = gson.fromJson(msg, JsonObject)
		val keys = Keys.generateAssymetricPair()
		val transaction = new Transaction(0, object, keys)
		Assert.assertTrue(transaction.verifySignature())
		
		val eve = Keys.generateAssymetricPair()
		val maliciousTransaction = new Transaction(0, object, eve.private, keys.public)
		Assert.assertFalse(maliciousTransaction.verifySignature())
	}
	
}