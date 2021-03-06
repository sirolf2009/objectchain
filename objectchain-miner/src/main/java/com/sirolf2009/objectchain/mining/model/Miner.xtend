package com.sirolf2009.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.MerkleTree
import com.sirolf2009.objectchain.common.exception.BranchExpansionException
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.node.NewBlock
import com.sirolf2009.objectchain.node.Node
import java.security.KeyPair
import java.util.List
import java.util.TreeSet
import java.util.function.Supplier
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.net.InetSocketAddress

abstract class Miner extends Node {

	val log = LoggerFactory.getLogger(Miner)
	var BlockMutable pendingBlock
	var boolean running

	new(Configuration configuration, Supplier<Kryo> kryoSupplier, List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		super(configuration, kryoSupplier, trackers, nodePort, keys)
	}

	new(Logger logger, Configuration configuration, Supplier<Kryo> kryoSupplier, List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		super(logger, configuration, kryoSupplier, trackers, nodePort, keys)
	}

	override onSynchronised() {
		new Thread([
			running = true
			kryoPool.run [ kryo |
				pendingBlock = new BlockMutable(new BlockHeaderMutable(blockchain.mainBranch.blocks.last.header.hash(kryo), blockchain.mainBranch.blocks.last.header.target), new TreeSet())
				pendingBlock.mutations.addAll(floatingMutations)
				calculateMerkle(kryo)
				mine(kryo, 0)
				return null
			]
		], "Mining") => [
			daemon = true
			start()
		]
		log.info("Mining started")
	}

	def mine(Kryo kryo, int startNonce) {
		while(running) {
			Thread.sleep(1000)
			synchronized(pendingBlock) {
				if(pendingBlock.mutations.size() > 0) {
					var nonce = startNonce
					var completed = false
					while(!completed && running) {
						pendingBlock.header.nonce = nonce
						if(pendingBlock.header.immutable().isBelowTarget(kryo)) {
							completed = true
							onCompleted(kryo, pendingBlock)
						} else {
							nonce++
						}
					}
				} else {
					log.debug("Waiting for mutations")
				}
			}
		}
	}

	override onMutationReceived(Mutation mutation) {
		synchronized(pendingBlock) {
			if(pendingBlock.mutations.size() < configuration.maxMutationsPerBlock) {
				pendingBlock.mutations.add(mutation)
				kryoPool.run [ kryo |
					calculateMerkle(kryo)
					return null
				]
			}
		}
	}

	def onCompleted(Kryo kryo, BlockMutable blockMutable) {
		try {
			val block = blockMutable.immutable()
			log.info("I have mined a block!")
			log.info(block.toString(kryo))
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
			pendingBlock = new BlockMutable(new BlockHeaderMutable(block.header.hash(kryo), target), new TreeSet())
		} catch(BranchExpansionException e) {
			log.error("The mined block didn't fit branch={}\nblock={}", e.branch.toString(kryo), e.newBlock.toString(kryo), e)
		}
	}

	def calculateMerkle(Kryo kryo) {
		if(pendingBlock.mutations !== null && pendingBlock.mutations.size() > 0) {
			pendingBlock.header.merkleRoot = MerkleTree.merkleTreeMutations(kryo, pendingBlock.mutations)
		}
	}

	override getLog() {
		return log
	}
	
	override close() throws Exception {
		super.close()
		running = false
	}

}
