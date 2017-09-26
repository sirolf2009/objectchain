package com.sirolf2009.objectchain.common.model

import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class Branch {
	
	val Block root
	val List<Block> blocks
	
	def size() {
		return blocks.size()
	}
	
}