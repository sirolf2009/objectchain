package com.sirolf2009.objectchain.common.crypto

import java.security.PrivateKey
import java.util.Base64
import java.util.List

import static extension com.sirolf2009.objectchain.common.crypto.CryptoHelper.*

class Decryption {

	def static decryptMessage(Pair<String, String> encrypted, PrivateKey key) {
		return decryptMessage(encrypted.key, encrypted.value, key)
	}

	def static decryptMessage(String encryptedKey, String encryptedMsg, PrivateKey key) {
		val decryptedKey = encryptedKey.decryptSecretKey(key)
		return encryptedMsg.decrypt(decryptedKey)
	}

	def static decryptPayload(Pair<byte[], byte[]> encrypted, PrivateKey key) {
		return decryptPayload(encrypted.key, encrypted.value, key)
	}

	def static decryptPayload(List<Byte> encryptedKey, List<Byte> encryptedMsg, PrivateKey key) {
		val decryptedKey = encryptedKey.decrypt(key).secretKey()
		return encryptedMsg.decrypt(decryptedKey)
	}

	def private static decryptSecretKey(String encryptedKey, PrivateKey key) {
		try {
			return Base64.decoder.decode(encryptedKey).decrypt(key).secretKey()
		} catch(Exception e) {
			throw new IllegalArgumentException("Failed to decrypt the secret key " + encryptedKey, e)
		}
	}

}
