package com.sirolf2009.objectchain.common.crypto

import java.security.MessageDigest
import java.util.List
import java.util.ArrayList

class Hashing {

	public static val algorithm = "SHA-256"
	public static val encoding = "UTF-8"
	
	def static doubleHashHex(String left, String right) {
		return toHexString(doubleHash(toByteArray(left), toByteArray(right)))
	}
	
	def static doubleHashHex(String msg) {
		return toHexString(doubleHash(toByteArray(msg)))
	}
	
	def static doubleHash(String msg) {
		return toHexString(doubleHash(msg.getBytes(encoding)))
	}
	
	def static hashHex(String msg) {
		return toHexString(doubleHash(toByteArray(msg)))
	}
	
	def static hash(String msg) {
		return toHexString((hash(msg.getBytes(encoding))))
	}
	
	def static List<Byte> toByteArray(String hex) {
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
		val string = Integer.toString(b.bitwiseAnd(0xFF), 16)
		if(string.length() < 2) {
			return "0"+string
		} else {
			return string
		}
	}
	
	def static doubleHash(List<Byte> bytes) {
		val digester = messageDigest
		return digester.digest(digester.digest(bytes))
	}
	
	def static doubleHash(List<Byte> bytes, List<Byte> bytes2) {
		val digester = messageDigest
		digester.update(bytes)
		digester.update(bytes2)
		return digester.digest(digester.digest())
	}
	
	def static hash(List<Byte> bytes) {
		return messageDigest.digest(bytes)
	}
	
	def static messageDigest() {
		return MessageDigest.getInstance(algorithm)
	}
	
}