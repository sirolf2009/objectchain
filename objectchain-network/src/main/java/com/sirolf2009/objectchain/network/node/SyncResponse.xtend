package com.sirolf2009.objectchain.network.node

import com.sirolf2009.objectchain.common.model.Block
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString
import com.sirolf2009.objectchain.common.model.Mutation

@ToString
@Accessors
@EqualsHashCode
class SyncResponse {
	
	var List<Block> newBlocks
	var List<Mutation> floatingMutations
	
}