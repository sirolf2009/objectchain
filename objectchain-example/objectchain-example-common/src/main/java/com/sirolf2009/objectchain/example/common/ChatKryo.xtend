package com.sirolf2009.objectchain.example.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Transaction
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.example.common.model.ClaimUsername

class ChatKryo {
	
	def static getKryo() {
		val kryo = new Kryo()
		//These are required by the standard library
		kryo.register(Block)
		kryo.register(BlockHeader)
		kryo.register(Transaction)
		
		//These are your own custom objects
		kryo.register(Message)
		kryo.register(ClaimUsername)
		
		return kryo
	}
	
}