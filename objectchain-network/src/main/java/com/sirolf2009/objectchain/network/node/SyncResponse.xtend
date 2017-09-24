package com.sirolf2009.objectchain.network.node

import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Mutation
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@ToString
@Accessors
@EqualsHashCode
class SyncResponse {
	
	var Block[] newBlocks
	var Mutation[] floatingMutations
	
}