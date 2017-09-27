package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.Serializer
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import java.util.TreeSet

class SerializerBlock extends Serializer<Block> {
	
	override read(Kryo kryo, Input input, Class<Block> type) {
		val header = kryo.readObject(input, BlockHeader)
		val mutations = kryo.readObject(input, typeof(Mutation[]))
		return new Block(header, newImmutableSet(new TreeSet(mutations)))
	}
	
	override write(Kryo kryo, Output output, Block object) {
		kryo.writeObject(output, object.header)
		kryo.writeObject(output, object.mutations.toArray(newArrayOfSize(object.mutations.size())))
	}
	
}