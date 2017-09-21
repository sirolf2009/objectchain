package com.sirolf2009.objectchain.network

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Transaction
import com.sirolf2009.objectchain.network.node.NewTransaction
import com.sirolf2009.objectchain.network.node.SyncRequest
import java.security.PublicKey
import java.util.Optional
import com.sirolf2009.objectchain.network.node.SyncResponse

class KryoRegistrationNode {
	
	def static register(Kryo kryo) {
		kryo.register(NewTransaction)
		kryo.register(Transaction)
		kryo.register(PublicKey)
		kryo.register(SyncRequest)
		kryo.register(Optional)
		kryo.register(SyncResponse)
	}
	
}