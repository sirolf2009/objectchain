package com.sirolf2009.objectchain.common.crypto

import java.io.File
import java.io.FileOutputStream
import java.nio.file.Files
import java.security.PrivateKey
import java.security.PublicKey
import java.security.SecureRandom
import java.util.List

class Keys {
	
	def static generatePair() {
		return generatePair(1024)
	}
	
	def static generatePair(int length) {
		val keyGenerator = CryptoHelper.keyPairGenerator
		keyGenerator.initialize(length, SecureRandom.getInstance("SHA1PRNG"))
		return keyGenerator.generateKeyPair()
	}
	
	def static readPrivateKeyFromFile(File file) {
		return CryptoHelper.privateKey(Files.readAllBytes(file.toPath()))
	}
	
	def static readPublicKeyFromFile(File file) {
		return CryptoHelper.publicKey(Files.readAllBytes(file.toPath()))
	}
	
	def static writeKeyToFile(PublicKey key, File file) {
		key.encoded.writeKeyToFile(file)
	}
	
	def static writeKeyToFile(PrivateKey key, File file) {
		key.encoded.writeKeyToFile(file)
	}
	
	def static writeKeyToFile(List<Byte> key, File file) {
		val out = new FileOutputStream(file)
		out.write(key)
		out.close()
	}
	
}