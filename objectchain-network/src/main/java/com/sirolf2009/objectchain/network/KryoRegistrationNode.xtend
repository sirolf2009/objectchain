package com.sirolf2009.objectchain.network

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.network.node.SyncRequest
import java.security.PublicKey
import java.util.Optional
import com.sirolf2009.objectchain.network.node.SyncResponse
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.node.NewMutation

class KryoRegistrationNode {
	
	def static register(Kryo kryo) {
		kryo.register(NewMutation)
		kryo.register(Mutation)
		kryo.register(PublicKey)
		kryo.register(SyncRequest)
		kryo.register(Optional)
		kryo.register(SyncResponse)
	}
	
}