package com.sirolf2009.objectchain.common.interfaces

import com.sirolf2009.objectchain.common.model.Mutation
import java.util.Set

interface IBlock extends IHashable {
	
	def IBlockHeader getHeader()
	def Set<Mutation> getMutations()
	
}