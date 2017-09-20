package com.sirolf2009.objectchain.common.model

import com.sirolf2009.objectchain.common.interfaces.IHashable
import java.security.KeyPair
import java.security.PrivateKey
import java.security.PublicKey
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.objectchain.common.crypto.CryptoHelper.*

@Data class Transaction implements Comparable<Transaction>, IHashable {
	
	val short version = 1 as short
	val int objectID
	val Object object
	val String signature
	val PublicKey publicKey
	
	new(int objectID, Object object, KeyPair keys) {
		this(objectID, object, keys.private, keys.public)
	}
	
	new(int objectID, Object object, PrivateKey privateKey, PublicKey publicKey) {
		this(objectID, object, object.toString().sign(privateKey), publicKey)
	}
	
	new(int objectID, Object object, String signature, PublicKey publicKey) {
		this.objectID = objectID
		this.object = object
		this.signature = signature
		this.publicKey = publicKey
	}
	
	def verifySignature() {
		return verify(object.toString(), signature, publicKey)
	}
	
	override compareTo(Transaction other) {
		return hash().compareTo(other.hash())
	}
	
}