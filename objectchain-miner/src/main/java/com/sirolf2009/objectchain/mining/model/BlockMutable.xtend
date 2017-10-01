package com.sirolf2009.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.interfaces.IBlock
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Mutation
import java.util.TreeSet
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.MerkleTree

/**
 * A mutable version of {@link Block} to reduce memory usage when mining
 */
@Accessors
@EqualsHashCode
@ToString
class BlockMutable implements IBlock {
	
	val BlockHeaderMutable header
	val TreeSet<Mutation> mutations
	
	def addMutation(Kryo kryo, Configuration configuration, Mutation mutation) {
		if(mutations.size() < configuration.maxMutationsPerBlock) {
			mutations.add(mutation)
			header.merkleRoot = MerkleTree.merkleTreeMutations(kryo, mutations)
		} else {
			throw new IllegalStateException("Could not add mutation, it would exceed maxMutationsPerBlock="+configuration.maxMutationsPerBlock+", mutation="+mutation.toString(kryo))
		}
	}

	def immutable() {
		return new Block(header.immutable(), new TreeSet(mutations.toArray().clone.toList()))
	}
	
	def toString(Kryo kryo) {
		return '''
			Block «header.hash(kryo).toHexString()» [
				version=«header.version»
				prevBlock=«header.previousBlock.toHexString()»
				merkleRoot=«header.merkleRoot.toHexString()»
				time=«header.time»
				target=«header.target.toString(16)»
				nonce=«header.nonce»
				«mutations.size()» Mutations [
				«FOR m : mutations.toList()»
					«m.toString(kryo)»
				«ENDFOR»
				]
			]
		'''
	}
	
}