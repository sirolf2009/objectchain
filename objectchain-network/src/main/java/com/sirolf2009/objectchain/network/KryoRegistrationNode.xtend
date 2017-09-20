package com.sirolf2009.objectchain.network

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Transaction
import com.sirolf2009.objectchain.network.node.NewTransaction
import java.security.PublicKey

class KryoRegistrationNode {
	
	def static register(Kryo kryo) {
		kryo.register(NewTransaction)
		kryo.register(Transaction)
		kryo.register(PublicKey)
	}
	
}