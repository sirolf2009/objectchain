package com.sirolf2009.objectchain.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Message
import com.sirolf2009.objectchain.common.model.Transaction

class TestKryo {
	
	def static getKryo() {
		val kryo = new Kryo()
		kryo.register(Block)
		kryo.register(BlockHeader)
		kryo.register(Transaction)
		
		kryo.register(Message)
		return kryo
	}
	
}