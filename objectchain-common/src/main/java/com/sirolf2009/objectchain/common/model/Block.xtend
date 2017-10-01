package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.exception.BlockVerificationException
import com.sirolf2009.objectchain.common.exception.MutationVerificationException
import com.sirolf2009.objectchain.common.interfaces.IBlock
import java.math.BigInteger
import java.util.TreeSet
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class Block implements IBlock {

	val BlockHeader header
	val TreeSet<Mutation> mutations

	override hash(Kryo kryo) {
		return header.hash(kryo)
	}

	def void verify(Kryo kryo, Configuration configuration) throws BlockVerificationException {
		if(header.previousBlock.size() == 0 && header.merkleRoot.size() == 0 && mutations.size() == 0) {
			return //genesis block
		}
		if(mutations.size() == 0) {
			throw new BlockVerificationException(this, "Block does not have mutations")
		}
		if(!header.isBelowTarget(kryo)) {
			throw new BlockVerificationException(this, '''Block is not below target, block=«new BigInteger(header.hash(kryo).toHexString(), 16)» target=«header.target»''')
		}
		try {
			mutations.forEach[verify(kryo, configuration)]
		} catch(MutationVerificationException e) {
			throw new BlockVerificationException(this, "Failed to verify mutation", e)
		}
		if(!MerkleTree.merkleTreeMutations(kryo, mutations).equals(header.merkleRoot)) {
			throw new BlockVerificationException(this, '''Wrong merkleTree, expected=«MerkleTree.merkleTreeMutations(kryo, mutations).toHexString()», actual=«header.merkleRoot.toHexString()»''')
		}
		if(mutations.size() > configuration.maxMutationsPerBlock) {
			throw new BlockVerificationException(this, '''block exceeds max mutations «configuration.maxMutationsPerBlock» with «mutations.size()»''')
		}
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
