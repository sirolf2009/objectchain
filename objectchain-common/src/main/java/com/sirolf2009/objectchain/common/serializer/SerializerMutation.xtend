package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.Serializer
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.crypto.CryptoHelper
import com.sirolf2009.objectchain.common.model.Mutation

class SerializerMutation extends Serializer<Mutation> {
	
	override read(Kryo kryo, Input input, Class<Mutation> type) {
		val id = input.readInt()
		val object = kryo.readClassAndObject(input)
		val signature = input.readString()
		val key = kryo.readObject(input, typeof(Byte[]))
		return new Mutation(id, object, signature, CryptoHelper.publicKey(key))
	}
	
	override write(Kryo kryo, Output output, Mutation object) {
		output.writeInt(object.objectID)
		kryo.writeClassAndObject(output, object.object)
		output.writeString(object.signature)
		kryo.writeObject(output, object.publicKey.encoded.map[it as Byte].toArray(newArrayOfSize(object.publicKey.encoded.size())))
	}
	
}