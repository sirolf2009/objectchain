package com.sirolf2009.objectchain.common.model

import com.google.gson.JsonObject
import java.security.KeyPair
import java.security.PrivateKey
import java.security.PublicKey
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.objectchain.common.crypto.CryptoHelper.*

@Data class Transaction {
	
	val short version = 1 as short
	val int objectID
	val JsonObject object
	val String signature
	val PublicKey publicKey
	
	new(int objectID, JsonObject object, KeyPair keys) {
		this(objectID, object, keys.private, keys.public)
	}
	
	new(int objectID, JsonObject object, PrivateKey privateKey, PublicKey publicKey) {
		this(objectID, object, object.toString().sign(privateKey), publicKey)
	}
	
	new(int objectID, JsonObject object, String signature, PublicKey publicKey) {
		this.objectID = objectID
		this.object = object
		this.signature = signature
		this.publicKey = publicKey
	}
	
	def verifySignature() {
		return verify(object.toString(), signature, publicKey)
	}
	
}