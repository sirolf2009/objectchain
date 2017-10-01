package com.sirolf2009.objectchain.common.interfaces

import com.sirolf2009.objectchain.common.model.Block

@FunctionalInterface
interface IState {
	
	def IState apply(Block block)
	
}