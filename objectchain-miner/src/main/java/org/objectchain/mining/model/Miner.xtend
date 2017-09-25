package org.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.network.node.NewBlock
import com.sirolf2009.objectchain.node.Node
import java.security.KeyPair
import java.util.ArrayList
import java.util.Date
import java.util.List

abstract class Miner extends Node {

	var BlockMutable pendingBlock

	new(Kryo kryo, List<String> trackers, int nodePort, KeyPair keys) {
		super(kryo, trackers, nodePort, keys)
	}

	override start() {
		super.start()
	}
	
	override onSynchronised() {
		pendingBlock = new BlockMutable(new BlockHeaderMutable(blockchain.blocks.last.header.hash(kryo), new ArrayList(), blockchain.blocks.last.header.target), floatingMutations) => [
			header.time = new Date()
		]
		mine(pendingBlock, 0)
	}

	def mine(BlockMutable block, int startNonce) {
		while(true) {
			var nonce = startNonce
			var completed = false
			while(!completed) {
				block.header.nonce = nonce
				block.header.time.time = System.currentTimeMillis()
				if(block.header.isBelowTarget(kryo)) {
					completed = true
					onCompleted(block)
				} else {
					nonce++
				}
			}
		}
	}

	def onCompleted(BlockMutable blockMutable) {
		val block = blockMutable.immutable()
		val newBlock = new NewBlock() => [
			it.block = block
		]
		submitMutation(newBlock)
		floatingMutations.clear()
		pendingBlock = new BlockMutable(new BlockHeaderMutable(block.header.hash(kryo), new ArrayList(), block.header.target), floatingMutations) => [
			header.time = new Date()
		]
	}

}
