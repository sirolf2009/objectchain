package com.sirolf2009.objectchain.network.node

import com.sirolf2009.objectchain.common.model.Hash
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@ToString
@Accessors
@EqualsHashCode
class SyncRequest {
	
	var Optional<Hash> lastKnownBlock
	var Optional<Integer> amountOfBlocks
	
}