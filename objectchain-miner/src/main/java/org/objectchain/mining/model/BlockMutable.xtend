package org.objectchain.mining.model

import com.sirolf2009.objectchain.common.interfaces.IBlock
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Mutation
import java.util.Set
import java.util.TreeSet
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

/**
 * A mutable version of {@link Block} to reduce memory usage when mining
 */
@Accessors
@EqualsHashCode
@ToString
class BlockMutable implements IBlock {
	
	val BlockHeaderMutable header
	val Set<Mutation> mutations
	
	def immutable() {
		return new Block(header.immutable(), new TreeSet(mutations.clone.toList()))
	}
	
}