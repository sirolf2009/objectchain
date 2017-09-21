package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class BlockChain {

	val Kryo kryo
	val List<Block> blocks

	def verify() {
		if(blocks.findFirst[!verify(kryo)] !== null) {
			return false
		}
		if(!hashCheck(0)) {
			return false
		}
		blocks.iterator
	}

	def hashCheck() {
		return hashCheck(0)
	}

	def hashCheck(int fromBlock) {
		var prevousHash = blocks.get(fromBlock).hash(kryo)
		for (var i = fromBlock + 1; i < blocks.size(); i++) {
			if(!blocks.get(i).header.previousBlock.equals(prevousHash)) {
				return false
			}
		}
		return true
	}

}
