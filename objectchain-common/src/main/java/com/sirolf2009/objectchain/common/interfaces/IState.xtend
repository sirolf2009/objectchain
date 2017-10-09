package com.sirolf2009.objectchain.common.interfaces

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block

@FunctionalInterface
interface IState {
	
	def IState apply(Kryo kryo, Block block)
	
}