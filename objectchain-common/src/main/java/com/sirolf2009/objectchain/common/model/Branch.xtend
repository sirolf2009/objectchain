package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import java.math.BigInteger
import com.sirolf2009.objectchain.common.exception.BlockVerificationException
import com.sirolf2009.objectchain.common.exception.BranchVerificationException
import com.sirolf2009.objectchain.common.exception.BranchExpansionException

@Data class Branch {

	val Block root
	val List<Block> blocks

	def canExpandWith(Kryo kryo, Block block) {
		return lastBlock.hash(kryo).equals(block.header.previousBlock)
	}

	def addBlock(Kryo kryo, Configuration configuration, Block block) {
		try {
			blocks.add(block)
			verify(kryo, configuration)
		} catch(Exception e) {
			blocks.remove(block)
			throw new BranchExpansionException(this, block, "Failed to add block to the chain", e)
		}
	}

	def void verify(Kryo kryo, Configuration configuration) throws BranchVerificationException {
		try {
			blocks.forEach[verify(kryo, configuration)]
		} catch(BlockVerificationException e) {
			throw new BranchVerificationException(this, e.block.getPreviousBlock(), e.block, "Failed to verify block", e)
		}
		hashCheck(kryo)
		targetCheck(kryo, configuration)
	}

	def targetCheck(Kryo kryo, Configuration configuration) throws BranchVerificationException {
		blocks.forEach [
			val shouldRetarget = shouldRetarget(configuration.targetValidity)
			val hasRetargeted = blocks.get(blocks.indexOf(it) - 1).header.target.equals(header.target)
			if(shouldRetarget && !hasRetargeted) {
				throw new BranchVerificationException(this, it.getPreviousBlock(), it, "Target should have changed")
			}
			if(!shouldRetarget && hasRetargeted) {
				throw new BranchVerificationException(this, it.getPreviousBlock(), it, "Target should not have changed")
			}
		]
	}

	def hashCheck(Kryo kryo) throws BranchVerificationException {
		var prevousHash = blocks.get(0).hash(kryo)
		for (var i = 0 + 1; i < size(); i++) {
			if(!blocks.get(i).header.previousBlock.equals(prevousHash)) {
				throw new BranchVerificationException(this, blocks.get(i - 1), blocks.get(i), "prevHash does not point to the previous hash")
			}
		}
	}

	def add(Kryo kryo, Configuration configuration, Block block) {
		block.verify(kryo, configuration)
		blocks.add(block)
	}

	def shouldRetarget(int targetValidity) {
		return shouldRetarget(targetValidity, blocks.get(blocks.size() - 1))
	}

	def shouldRetarget(int targetValidity, Block block) {
		return (blocks.indexOf(block) + 1) % targetValidity == 0
	}

	def getNewTarget(int targetValidity, long blockDuration) {
		val blocksSinceLastRetarget = blocks.get(blocks.size() - targetValidity)
		val previous = blocks.get(blocks.size() - 1)
		val timeTaken = previous.header.time.time - blocksSinceLastRetarget.header.time.time
		return previous.header.target.getNewTarget(targetValidity, blockDuration, timeTaken)
	}

	def static getNewTarget(BigInteger currentTarget, int targetValidity, long blockDuration, long retargetDuration) {
		return currentTarget.multiply(BigInteger.valueOf(((blockDuration.doubleValue * targetValidity.doubleValue) / retargetDuration.doubleValue).longValue))
	}

	def getPreviousBlock(Block block) {
		return blocks.get(blocks.indexOf(block) - 1)
	}

	def getLastBlock() {
		return blocks.get(blocks.size() - 1)
	}

	def size() {
		return blocks.size()
	}

}
