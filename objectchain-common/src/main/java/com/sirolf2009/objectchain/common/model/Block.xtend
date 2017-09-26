package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.interfaces.IBlock
import java.util.Set
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class Block implements IBlock {

	static val log = LoggerFactory.getLogger(Block)
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
			log.debug("wrong signature")
			return false
		}
		if(!MerkleTree.merkleTreeMutations(kryo, mutations).equals(header.merkleRoot)) {
			log.debug("wrong merkleTree")
			log.debug("expected = " +MerkleTree.merkleTreeMutations(kryo, mutations).toHexString())
			log.debug("actual= " +header.merkleRoot.toHexString())
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
	
	def toString(Kryo kryo) {
		return 
		'''
		Block «hash(kryo).toHexString()» [
			version=«header.version»
			prevBlock=«header.previousBlock.toHexString()»
			merkleRoot=«header.merkleRoot.toHexString()»
			time=«header.time»
			target=«header.target.toString(16)»
			nonce=«header.nonce»
			«mutations.size()» Mutations [
			«FOR m : mutations.toList().reverseView()»
				«m.toString(kryo)»
			«ENDFOR»
			]
		]
		'''
	}

}
