package com.sirolf2009.objectchain.network

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.common.serializer.SerializerBlock
import com.sirolf2009.objectchain.common.serializer.SerializerBlockHeader
import com.sirolf2009.objectchain.network.node.NewMutation
import com.sirolf2009.objectchain.network.node.SyncRequest
import com.sirolf2009.objectchain.network.node.SyncResponse
import java.math.BigInteger
import java.security.PublicKey
import java.util.Date
import java.util.Optional
import com.sirolf2009.objectchain.common.serializer.SerializerMutation

class KryoRegistrationNode {
	
	def static register(Kryo kryo) {
		kryo.register(NewMutation)
		kryo.register(Mutation, new SerializerMutation())
		kryo.register(typeof(Mutation[]))
		kryo.register(PublicKey)
		kryo.register(SyncRequest)
		kryo.register(Optional)
		kryo.register(SyncResponse)
		kryo.register(Block, new SerializerBlock())
		kryo.register(typeof(Block[]))
		kryo.register(typeof(Object[]))
		kryo.register(typeof(Byte[]))
		kryo.register(BlockHeader, new SerializerBlockHeader())
		kryo.register(BigInteger)
		kryo.register(Date)
	}
	
}