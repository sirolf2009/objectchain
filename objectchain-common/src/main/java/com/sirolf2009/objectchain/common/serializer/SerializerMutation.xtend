package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.Serializer
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.crypto.CryptoHelper
import com.sirolf2009.objectchain.common.model.Mutation

class SerializerMutation extends Serializer<Mutation> {
	
	override read(Kryo kryo, Input input, Class<Mutation> type) {
		val object = kryo.readClassAndObject(input)
		val signature = input.readString()
		val keySize = input.readInt()
		val key = (0 ..< keySize).map[input.readByte].toList()
		return new Mutation(object, signature, CryptoHelper.publicKey(key))
	}
	
	override write(Kryo kryo, Output output, Mutation object) {
		kryo.writeClassAndObject(output, object.object)
		output.writeString(object.signature)
		output.writeInt(object.publicKey.encoded.size())
		object.publicKey.encoded.forEach[output.writeByte(it)]
	}
	
}