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
		//TODO Transaction list must be non-empty
		//TODO Block hash must satisfy claimed nBits proof of work
		//TODO Block timestamp must not be more than two hours in the future
		//TODO For each transaction, apply mutation checks
		//TODO Reject if sum of transaction sig opcounts > MAX_BLOCK_SIGOPS
		//TODO Check that nBits value matches the difficulty rules
		//TODO Reject if timestamp is the median time of the last 11 blocks or before
		//TODO For certain old blocks (i.e. on initial block download) check that hash matches known values
		if(mutations.findFirst[!verifySignature()] !== null) {
			return false
		}
		if(!MerkleTree.merkleTreeMutations(kryo, mutations).equals(header.merkleRoot.toHexString())) {
			return false
		}
		return true
	}

	def canExpand(Kryo kryo, BlockChain chain) {
		return canExpand(kryo, chain.blocks.last)
	}

	def canExpand(Kryo kryo, Block block) {
		return header.previousBlock.equals(block.hash(kryo))
	}

}
