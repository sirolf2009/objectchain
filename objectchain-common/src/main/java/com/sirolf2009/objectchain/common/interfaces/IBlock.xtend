package com.sirolf2009.objectchain.common.interfaces

import java.util.List
import com.sirolf2009.objectchain.common.model.Mutation

interface IBlock extends IHashable {
	
	def IBlockHeader getHeader()
	def List<Mutation> getMutations()
	
}