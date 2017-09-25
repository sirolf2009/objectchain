package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.Serializer
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.model.BlockHeader
import java.math.BigInteger
import java.util.Date

class SerializerBlockHeader extends Serializer<BlockHeader> {
	
	override read(Kryo kryo, Input input, Class<BlockHeader> type) {
		val previousBlock = kryo.readObject(input, typeof(Byte[]))
		val merkleRoot = kryo.readObject(input, typeof(Byte[]))
		val time = kryo.readObject(input, Date)
		val target = kryo.readObject(input, BigInteger)
		val nonce = input.readInt()
		return new BlockHeader(previousBlock, merkleRoot, time, target, nonce)
	}
	
	override write(Kryo kryo, Output output, BlockHeader object) {
		kryo.writeObject(output, object.previousBlock.toArray(newArrayOfSize(object.previousBlock.size())))
		kryo.writeObject(output, object.merkleRoot.toArray(newArrayOfSize(object.merkleRoot.size())))
		kryo.writeObject(output, object.time)
		kryo.writeObject(output, object.target)
		output.writeInt(object.nonce)
	}
	
}