package com.sirolf2009.objectchain.common.model

import com.sirolf2009.objectchain.common.interfaces.IBlock
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class Block implements IBlock {
	
	val BlockHeader header
	val List<Transaction> transactions
	
}