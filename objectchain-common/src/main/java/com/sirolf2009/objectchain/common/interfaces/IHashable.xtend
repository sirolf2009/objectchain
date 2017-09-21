package com.sirolf2009.objectchain.common.interfaces

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Output

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import java.io.ByteArrayOutputStream

interface IHashable {
	
	def hash(Kryo kryo) {
		getBytes(kryo).doubleHash().toList()
	}
	
	def getBytes(Kryo kryo) {
		val buffer = new ByteArrayOutputStream()
		val out = new Output(buffer)
		kryo.writeObject(out, this)
		out.close()
		return buffer.toByteArray.toList()
	}
	
}