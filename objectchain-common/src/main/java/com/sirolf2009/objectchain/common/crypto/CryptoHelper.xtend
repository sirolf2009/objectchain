package com.sirolf2009.objectchain.common.crypto

import java.security.KeyFactory
import java.security.KeyPairGenerator
import java.security.PrivateKey
import java.security.PublicKey
import java.security.Signature
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import java.util.Base64
import java.util.List
import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.spec.SecretKeySpec

class CryptoHelper {

	public static val symmetricAlgorithm = "AES"
	public static val assymetricAlgorithm = "RSA"
	public static val signingAlgorithm = "SHA1WithRSA"
	public static val transformation = "RSA/ECB/PKCS1Padding"
	public static val encoding = "UTF-8"

	def static verify(String expected, String sign, PublicKey key) {
		try {
			return verify(expected.getBytes(encoding), Base64.decoder.decode(sign), key)
		} catch(Exception e) {
			throw new IllegalArgumentException("Failed to verify " + sign + " as " + expected, e)
		}
	}

	def static sign(String msg, PrivateKey key) {
		try {
			val signature = getSignature()
			signature.initSign(key)
			signature.update(msg.getBytes(encoding))
			return Base64.encoder.encodeToString(signature.sign())
		} catch(Exception e) {
			throw new IllegalArgumentException("Failed to sign " + msg, e)
		}
	}

	def static verify(List<Byte> expected, List<Byte> sign, PublicKey key) {
		val signature = getSignature()
		signature.initVerify(key)
		signature.update(expected)
		return signature.verify(sign)
	}

	def static sign(List<Byte> msg, PrivateKey key) {
		val signature = getSignature()
		signature.initSign(key)
		signature.update(msg)
		return signature.sign()
	}

	def static encrypt(String msg, SecretKey key) {
		try {
			val bytes = msg.getBytes(encoding)
			val encrypted = bytes.encrypt(key)
			return Base64.encoder.encodeToString(encrypted)
		} catch(Exception e) {
			throw new IllegalArgumentException("Failed to encrypt msg " + msg, e)
		}
	}

	def static decrypt(String msg, SecretKey key) {
		try {
			val encrypted = Base64.decoder.decode(msg)
			val decrypted = encrypted.decrypt(key)
			return new String(decrypted, encoding)
		} catch(Exception e) {
			throw new IllegalArgumentException("Failed to decrypt msg " + msg, e)
		}
	}

	def static encrypt(String msg, PublicKey key) {
		try {
			val bytes = msg.getBytes(encoding)
			val encrypted = bytes.encrypt(key)
			return Base64.encoder.encodeToString(encrypted)
		} catch(Exception e) {
			throw new IllegalArgumentException("Failed to encrypt msg " + msg, e)
		}
	}

	def static decrypt(String msg, PrivateKey key) {
		try {
			val encrypted = Base64.decoder.decode(msg)
			val decrypted = encrypted.decrypt(key)
			return new String(decrypted, encoding)
		} catch(Exception e) {
			throw new IllegalArgumentException("Failed to encrypt msg " + msg, e)
		}
	}

	def static encrypt(List<Byte> input, SecretKey key) {
		val cipher = getSecretCipher()
		cipher.init(Cipher.ENCRYPT_MODE, key)
		return cipher.doFinal(input)
	}

	def static decrypt(List<Byte> input, SecretKey key) {
		val cipher = getSecretCipher()
		cipher.init(Cipher.DECRYPT_MODE, key)
		return cipher.doFinal(input)
	}

	def static encrypt(List<Byte> input, PublicKey key) {
		val cipher = getAssymetricCipher()
		cipher.init(Cipher.ENCRYPT_MODE, key)
		return cipher.doFinal(input)
	}

	def static decrypt(List<Byte> input, PrivateKey key) {
		val cipher = getAssymetricCipher()
		cipher.init(Cipher.DECRYPT_MODE, key)
		return cipher.doFinal(input)
	}
	
	def static secretKey(List<Byte> bytes) {
		return new SecretKeySpec(bytes, symmetricAlgorithm)
	}

	def static privateKey(List<Byte> bytes) {
		return getKeyFactory().generatePrivate(new PKCS8EncodedKeySpec(bytes))
	}

	def static publicKey(List<Byte> bytes) {
		return getKeyFactory().generatePublic(new X509EncodedKeySpec(bytes.map[it as byte]))
	}

	def static KeyPairGenerator getKeyPairGenerator() {
		return KeyPairGenerator.getInstance(CryptoHelper.assymetricAlgorithm)
	}

	def static getSignature() {
		return Signature.getInstance(signingAlgorithm)
	}

	def static getKeyFactory() {
		return KeyFactory.getInstance(CryptoHelper.assymetricAlgorithm)
	}

	def static getSecretCipher() {
		return Cipher.getInstance(symmetricAlgorithm)
	}

	def static getAssymetricCipher() {
		return Cipher.getInstance(transformation)
	}

}
