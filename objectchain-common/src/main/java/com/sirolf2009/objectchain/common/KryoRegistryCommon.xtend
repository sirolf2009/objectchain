package com.sirolf2009.objectchain.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.common.serializer.SerializerBlock
import com.sirolf2009.objectchain.common.serializer.SerializerBlockHeader
import com.sirolf2009.objectchain.common.serializer.SerializerMutation
import java.math.BigInteger
import java.security.PublicKey
import java.util.ArrayList
import java.util.Date

class KryoRegistryCommon {

	def static register(Kryo it) {
		register(ArrayList)
		register(Date)
		register(BigInteger)
		register(PublicKey)
		register(typeof(Byte[]))
		
		register(Block, new SerializerBlock())
		register(BlockHeader, new SerializerBlockHeader())
		register(Mutation, new SerializerMutation())
		
		register(typeof(Mutation[]))
	}

}
