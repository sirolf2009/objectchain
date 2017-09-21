package org.objectchain.mining.model

import com.sirolf2009.objectchain.node.Node
import java.util.List
import com.esotericsoftware.kryo.Kryo

class Miner extends Node {
	
	var BlockMutable pendingBlock

	new(Kryo kryo, List<String> trackers, int nodePort) {
		super(kryo, trackers, nodePort)
	}
	
	override start() {
		super.start()
		mine(pendingBlock, 0)
	}
	
	def mine(BlockMutable block, int startNonce) {
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

	def static onCompleted(BlockMutable block) {
	}

}
