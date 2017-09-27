package org.objectchain.mining.model

import com.sirolf2009.objectchain.common.interfaces.IBlock
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Mutation
import java.util.Collections
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString
import java.util.stream.Collectors

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
		return new Block(header.immutable(), Collections.unmodifiableSet(mutations.stream().collect(Collectors.toSet())))
	}
	
}