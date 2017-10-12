package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.interfaces.IHashable
import java.security.KeyPair
import java.security.PrivateKey
import java.security.PublicKey
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.objectchain.common.crypto.CryptoHelper.*
import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import com.sirolf2009.objectchain.common.exception.MutationVerificationException

@Data class Mutation implements IHashable, Comparable<Mutation> {
	
	val short version = 1 as short
	val Object object
	val String signature
	val PublicKey publicKey
	
	new(Object object, Kryo kryo, KeyPair keys) {
		this(object, kryo, keys.private, keys.public)
	}
	
	new(Object object, Kryo kryo, PrivateKey privateKey, PublicKey publicKey) {
		this(object, kryo.hash(object).toHexString().sign(privateKey), publicKey)
	}
	
	new(Object object, String signature, PublicKey publicKey) {
		this.object = object
		this.signature = signature
		this.publicKey = publicKey
	}
	
	def verify(Kryo kryo, Configuration configuration) throws MutationVerificationException {
		if(!verifySignature(kryo)) {
			throw new MutationVerificationException(this, "Signature is not valid")
		}
		if(getBytes(kryo).size() > configuration.maxSizePerMutation) {
			throw new MutationVerificationException(this, '''Mutation exceeds max size. maxSize=«configuration.maxSizePerMutation» size=«getBytes(kryo).size()»''')
		}
	}
	
	def verifySignature(Kryo kryo) {
		return verify(kryo.hash(object).toHexString(), signature, publicKey)
	}
	
	override compareTo(Mutation o) {
		if(signature.compareTo(o.signature) != 0) {
			return signature.compareTo(o.signature)
		} else if(signature.compareTo(o.signature) != 0) {
			return signature.compareTo(o.signature)
		} else if(publicKey.encoded.toHexString().compareTo(o.publicKey.encoded.toHexString()) != 0) {
			return publicKey.encoded.toHexString().compareTo(o.publicKey.encoded.toHexString())
		} else {
			return 0
		}
	}
	
	def toString(Kryo kryo) {
		return 
		'''
		Mutation «hash(kryo).toHexString()» [
			object = «object» 
			key = «publicKey.encoded.toHexString()»
			signature = «signature»
		]
		'''
	}
	
}