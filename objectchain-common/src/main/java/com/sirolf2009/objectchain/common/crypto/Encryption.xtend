package com.sirolf2009.objectchain.common.crypto

import java.security.PublicKey
import java.util.Base64
import java.util.List

import static extension com.sirolf2009.objectchain.common.crypto.CryptoHelper.*

class Encryption {
	
	def static encryptMessage(String msg, PublicKey key) {
		val secretKey = Keys.generateSecretKey()
		val encryptedMsg = msg.encrypt(secretKey)
		val encryptedKey = Base64.encoder.encodeToString(secretKey.encoded.encrypt(key))
		return encryptedKey -> encryptedMsg 
	}

	def static encryptPayload(List<Byte> msg, PublicKey key) {
		val secretKey = Keys.generateSecretKey()
		val encryptedMsg = msg.encrypt(secretKey)
		val encryptedKey = secretKey.encoded.encrypt(key)
		return encryptedKey -> encryptedMsg 
	}
	
}