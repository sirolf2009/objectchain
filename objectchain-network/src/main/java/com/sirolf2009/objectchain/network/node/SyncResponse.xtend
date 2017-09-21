package com.sirolf2009.objectchain.network.node

import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Transaction
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@ToString
@Accessors
@EqualsHashCode
class SyncResponse {
	
	var List<Block> newBlocks
	var List<Transaction> floatingTransactions
	
}