package com.sirolf2009.objectchain.network

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.KryoRegistryCommon
import com.sirolf2009.objectchain.network.node.NewBlock
import com.sirolf2009.objectchain.network.node.NewMutation
import com.sirolf2009.objectchain.network.node.SyncRequest
import com.sirolf2009.objectchain.network.node.SyncResponse

class KryoRegistrationNode {
	
	def static register(Kryo kryo) {
		KryoRegistryCommon.register(kryo)
		kryo.register(NewMutation)
		kryo.register(SyncRequest)
		kryo.register(SyncResponse)
		kryo.register(typeof(Object[]))
		kryo.register(NewBlock)
	}
	
}