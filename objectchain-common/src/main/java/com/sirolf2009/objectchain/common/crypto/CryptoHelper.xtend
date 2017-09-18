package com.sirolf2009.objectchain.common.crypto

import java.security.KeyFactory
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import java.util.List
import javax.crypto.Cipher
import java.security.PrivateKey
import java.util.Base64
import java.security.KeyPairGenerator

class CryptoHelper {
	
	static val transformation = "RSA"
	static val encoding = "UTF-8"
	
	def static encrypt(String msg, PrivateKey key) {
		val bytes = msg.getBytes(encoding)
		val encrypted = bytes.encrypt(key)
		return Base64.encoder.encodeToString(encrypted)
	}
	
	def static decrypt(String msg, PrivateKey key) {
		val encrypted = Base64.decoder.decode(msg)
		val decrypted = encrypted.decrypt(key)
		return new String(decrypted, encoding)
	}
	
	def static encrypt(List<Byte> input, PrivateKey key) {
		val cipher = getCipher()
		cipher.init(Cipher.ENCRYPT_MODE, key)
		return cipher.doFinal(input)
	}
	
	def static decrypt(List<Byte> input, PrivateKey key) {
		val cipher = getCipher()
		cipher.init(Cipher.DECRYPT_MODE, key)
		return cipher.doFinal(input)
	}
	
	def static privateKey(List<Byte> bytes) {
		return getKeyFactory().generatePrivate(new PKCS8EncodedKeySpec(bytes))
	}
	
	def static publicKey(List<Byte> bytes) {
		return getKeyFactory().generatePrivate(new X509EncodedKeySpec(bytes))
	}
	
	def static KeyPairGenerator getKeyPairGenerator() {
		return KeyPairGenerator.getInstance(transformation)
	}
	
	def static KeyFactory getKeyFactory() {
		return KeyFactory.getInstance(transformation)
	}
	
	def static Cipher getCipher() {
		return Cipher.getInstance(transformation)
	}
	
}