package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.Serializer
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.model.Hash

class SerializerHash extends Serializer<Hash> {

	override read(Kryo kryo, Input input, Class<Hash> type) {
		val size = input.readInt()
		if(size == 0) {
			return new Hash(newArrayList())
		} else {
			return new Hash((0 ..< size).map[input.readByte()].toList())
		}
	}

	override write(Kryo kryo, Output output, Hash object) {
		output.writeInt(object.getBytes().size())
		object.getBytes.forEach[output.writeByte(it)]
	}

}
