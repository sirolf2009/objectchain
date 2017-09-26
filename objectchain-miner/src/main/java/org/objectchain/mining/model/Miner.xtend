package org.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.node.NewBlock
import com.sirolf2009.objectchain.node.Node
import java.security.KeyPair
import java.util.Date
import java.util.List
import org.slf4j.LoggerFactory

abstract class Miner extends Node {

	static val log = LoggerFactory.getLogger(Miner)
	var BlockMutable pendingBlock

	new(Kryo kryo, List<String> trackers, int nodePort, KeyPair keys) {
		super(kryo, trackers, nodePort, keys)
	}

	override onInitialized() {
		new Thread([
			pendingBlock = new BlockMutable(new BlockHeaderMutable(blockchain.blocks.last.header.hash(kryo), blockchain.blocks.last.header.target), floatingMutations) => [
				header.time = new Date()
			]
			calculateMerkle()
			mine(pendingBlock, 0)
		], "Mining").start()
		log.info("Mining started")
	}

	def mine(BlockMutable block, int startNonce) {
		while(true) {
			Thread.sleep(1000)
			synchronized(pendingBlock) {
				if(pendingBlock.mutations.size() > 0) {
					var nonce = startNonce
					var completed = false
					while(!completed) {
						block.header.nonce = nonce
						if(block.header.isBelowTarget(kryo)) {
							completed = true
							log.info("I have mined a block!")
							onCompleted(block)
						} else {
							nonce++
						}
					}
				} else {
					log.info("Waiting for mutations")
				}
			}
		}
	}

	override addMutation(Mutation mutation) {
		synchronized(pendingBlock) {
			if(super.addMutation(mutation)) {
				pendingBlock.header.merkleRoot = MerkleTree.merkleTreeMutations(kryo, floatingMutations)
				return true
			}
			return false
		}
	}

	def onCompleted(BlockMutable blockMutable) {
		val block = blockMutable.immutable()
		blockchain.blocks.add(block)
		val newBlock = new NewBlock() => [
			it.block = block
		]
		newBlock.broadcast()
		floatingMutations.clear()
		pendingBlock = new BlockMutable(new BlockHeaderMutable(block.header.hash(kryo), block.header.target), floatingMutations) => [
			header.time = new Date()
		]
		calculateMerkle()
	}

	def calculateMerkle() {
		if(pendingBlock.mutations !== null && pendingBlock.mutations.size() > 0) {
			pendingBlock.header.merkleRoot = MerkleTree.merkleTreeMutations(kryo, pendingBlock.mutations)
		}
	}

}
