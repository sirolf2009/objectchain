package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.annotations.Data

@Data class BlockChain {

	val List<Block> blocks
	val List<List<Block>> branches
	val Set<Block> orphanedBlocks

	def verify(Kryo kryo, int fromBlock) {
		if(blocks.subList(fromBlock, blocks.size()).findFirst[!verify(kryo)] !== null) {
			return false
		}
		if(!hashCheck(kryo, fromBlock)) {
			return false
		}
		return true
	}

	def hashCheck(Kryo kryo, int fromBlock) {
		var prevousHash = blocks.get(fromBlock).hash(kryo)
		for (var i = fromBlock + 1; i < blocks.size(); i++) {
			if(!blocks.get(i).header.previousBlock.equals(prevousHash)) {
				return false
			}
		}
		return true
	}

}
