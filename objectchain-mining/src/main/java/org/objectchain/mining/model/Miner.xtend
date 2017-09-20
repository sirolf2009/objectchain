package org.objectchain.mining.model

class Miner {
	
	def static mine(BlockMutable block, int startNonce) {
		var nonce = startNonce
		var completed = false
		while(!completed) {
			block.header.nonce = nonce
			if(block.header.isBelowTarget()) {
				completed = true
				onCompleted(block)
			}
		}
	}
	
	def static onCompleted(BlockMutable block) {
		
	}
	
}