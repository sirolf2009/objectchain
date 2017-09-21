package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.interfaces.IBlock
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.toHexString

@Data class Block implements IBlock {
	
	val BlockHeader header
	val List<Transaction> transactions
	
	def verify(Kryo kryo) {
		if(transactions.findFirst[!verifySignature()] !== null) {
			return false
		}
		if(!MerkleTree.merkleTreeTransactions(kryo, transactions).equals(header.merkleRoot.toHexString())) {
			return false
		}
		return true
	}
	
}