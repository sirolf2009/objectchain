package com.sirolf2009.objectchain.common.interfaces

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Output

import java.io.ByteArrayOutputStream

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

interface IHashable {
	
	def hash(Kryo kryo) {
		hash(kryo, this)
	}
	
	def getBytes(Kryo kryo) {
		getBytes(kryo, this)
	}
	
	def static hash(Kryo kryo, Object object) {
		getBytes(kryo, object).doubleHash().toList()
	}
	
	def static getBytes(Kryo kryo, Object object) {
		val buffer = new ByteArrayOutputStream()
		val out = new Output(buffer)
		kryo.writeObject(out, object)
		out.close()
		return buffer.toByteArray.toList()
	}
	
}