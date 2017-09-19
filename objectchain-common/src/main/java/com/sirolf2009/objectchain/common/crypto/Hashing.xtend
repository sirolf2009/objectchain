package com.sirolf2009.objectchain.common.crypto

import java.security.MessageDigest
import java.util.List
import java.util.ArrayList

class Hashing {

	public static val algorithm = "SHA-256"
	public static val encoding = "UTF-8"
	
	def static doubleHash(String msg) {
		return toHexString(doubleHash(msg.getBytes(encoding)))
	}
	
	def static hash(String msg) {
		return toHexString((hash(msg.getBytes(encoding))))
	}
	
	def static toByteArray(String hex) {
		val bytes = new ArrayList()
		for(var i = 0; i < hex.length(); i+= 2) {
			bytes.add(((Character.digit(hex.charAt(i), 16) << 4) + Character.digit(hex.charAt(i+1), 16)) as byte)
		}
		return bytes
	}
	
	def static toHexString(List<Byte> a) {
		return a.map[toHexString].join()
	}
	
	def static toHexString(byte b) {
		return Integer.toString(b.bitwiseAnd(0xFF) + 0x100, 16)
	}
	
	def static doubleHash(List<Byte> bytes) {
		val digester = messageDigest
		return digester.digest(digester.digest(bytes))
	}
	
	def static hash(List<Byte> bytes) {
		return messageDigest.digest(bytes)
	}
	
	def static messageDigest() {
		return MessageDigest.getInstance(algorithm)
	}
	
}