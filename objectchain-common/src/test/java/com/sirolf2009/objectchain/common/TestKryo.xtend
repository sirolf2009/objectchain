package com.sirolf2009.objectchain.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Message
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.common.serializer.SerializerBlock
import com.sirolf2009.objectchain.common.serializer.SerializerBlockHeader
import java.math.BigInteger
import java.util.ArrayList
import java.util.Date

class TestKryo {

	def static getKryo() {
		val kryo = new Kryo() => [
			register(ArrayList)
			register(Date)
			register(BigInteger)
			register(BlockHeader, new SerializerBlockHeader())

			register(Block, new SerializerBlock())
			register(Mutation)

			register(Message)
		]
		return kryo
	}

}
