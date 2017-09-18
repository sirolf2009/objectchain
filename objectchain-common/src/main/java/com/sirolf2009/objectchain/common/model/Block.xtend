package com.sirolf2009.objectchain.common.model

import org.eclipse.xtend.lib.annotations.Data
import java.util.List

@Data class Block {
	
	val BlockHeader header
	val List<Transaction> transactions
	
}