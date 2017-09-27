package org.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.exception.BranchExpansionException
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.node.NewBlock
import com.sirolf2009.objectchain.node.Node
import java.security.KeyPair
import java.util.Date
import java.util.List
import java.util.TreeSet
import org.slf4j.Logger
import org.slf4j.LoggerFactory

abstract class Miner extends Node {

	val log = LoggerFactory.getLogger(Miner)
	var BlockMutable pendingBlock

	new(Configuration configuration, Kryo kryo, List<String> trackers, int nodePort, KeyPair keys) {
		super(configuration, kryo, trackers, nodePort, keys)
	}

	new(Logger logger, Configuration configuration, Kryo kryo, List<String> trackers, int nodePort, KeyPair keys) {
		super(logger, configuration, kryo, trackers, nodePort, keys)
	}

	override onInitialized() {
		new Thread([
			pendingBlock = new BlockMutable(new BlockHeaderMutable(blockchain.mainBranch.blocks.last.header.hash(kryo), blockchain.mainBranch.blocks.last.header.target), new TreeSet()) => [
				header.time = new Date()
			]
			calculateMerkle()
			mine(0)
		], "Mining").start()
		log.info("Mining started")
	}

	def mine(int startNonce) {
		while(true) {
			Thread.sleep(1000)
			synchronized(pendingBlock) {
				if(pendingBlock.mutations.size() > 0) {
					var nonce = startNonce
					var completed = false
					while(!completed) {
						pendingBlock.header.nonce = nonce
						if(pendingBlock.header.immutable().isBelowTarget(kryo)) {
							completed = true
							onCompleted(pendingBlock)
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

	override onMutationReceived(Mutation mutation) {
		synchronized(pendingBlock) {
			if(pendingBlock.mutations.size() < configuration.maxMutationsPerBlock) {
				pendingBlock.mutations.add(mutation)
				calculateMerkle()
			}
		}
	}

	def onCompleted(BlockMutable blockMutable) {
		log.info(blockMutable.toString(kryo))
		try {
			val block = blockMutable.immutable()
			log.info("I have mined a block!")
			blockchain.mainBranch.addBlock(kryo, configuration, block)
			val newBlock = new NewBlock() => [
				it.block = block
			]
			newBlock.broadcast()
			floatingMutations.removeAll(block.mutations)
			val target = if(blockchain.mainBranch.shouldRetarget(configuration.targetValidity)) {
					blockchain.mainBranch.getNewTarget(configuration.targetValidity, configuration.blockDuration.toMillis())
				} else {
					block.header.target
				}
			pendingBlock = new BlockMutable(new BlockHeaderMutable(block.header.hash(kryo), target), new TreeSet()) => [
				header.time = new Date()
			]
		} catch(BranchExpansionException e) {
			log.error("The mined block didn't fit branch={}\nblock={}", e.branch, e.newBlock.toString(kryo), e)
		}
	}

	def calculateMerkle() {
		if(pendingBlock.mutations !== null && pendingBlock.mutations.size() > 0) {
			pendingBlock.header.merkleRoot = MerkleTree.merkleTreeMutations(kryo, pendingBlock.mutations)
		}
	}

	override getLog() {
		return log
	}

}
