package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.interfaces.IBlock
import java.util.Set
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.toHexString

@Data class Block implements IBlock {
	
	val BlockHeader header
	val Set<Mutation> mutations
	
	override hash(Kryo kryo) {
		return header.hash(kryo)
	}
	
	def verify(Kryo kryo) {
		if(mutations.findFirst[!verifySignature()] !== null) {
			return false
		}
		if(!MerkleTree.merkleTreeMutations(kryo, mutations).equals(header.merkleRoot.toHexString())) {
			return false
		}
		return true
	}
	
	def canExpand(Kryo kryo, BlockChain chain) {
		header.previousBlock.equals(chain.blocks.last.hash(kryo))
	}
	
}