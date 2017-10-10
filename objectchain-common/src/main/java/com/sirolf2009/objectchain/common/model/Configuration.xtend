package com.sirolf2009.objectchain.common.model

import java.math.BigInteger
import java.time.Duration
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.objectchain.common.interfaces.IState
import org.eclipse.xtend.lib.annotations.Accessors

@Data class Configuration {

	/** The amount of blocks that will maintain the target before recalculating */
	val int targetValidity
	/** How long every block should, on average, last for */
	val Duration blockDuration
	/** How many mutations are we allowed to hold per block */
	val int maxMutationsPerBlock
	/** How many bytes may 1 transaction be */
	val long maxSizePerMutation
	/** The initial target for the genesis block */
	val BigInteger initialTarget
	/** The initial state of the blockchain */
	val IState genesisState

	@Accessors public static class Builder {

		/** The amount of blocks that will maintain the target before recalculating */
		var int targetValidity = 2016
		/** How long every block should, on average, last for */
		var Duration blockDuration = Duration.ofMinutes(10)
		/** How many mutations are we allowed to hold per block */
		var int maxMutationsPerBlock = 512
		/** How many bytes may 1 transaction be */
		var long maxSizePerMutation = 2048
		/** The initial target for the genesis block */
		var BigInteger initialTarget = new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16)
		/** The initial state of the blockchain */
		var IState genesisState
		
		def build() {
			if(blockDuration === null) {
				throw new IllegalArgumentException("blockDuration cannot be null")
			}
			if(initialTarget === null) {
				throw new IllegalArgumentException("initialTarget cannot be null")
			}
			if(genesisState === null) {
				throw new IllegalArgumentException("genesisState cannot be null")
			}
			return new Configuration(targetValidity, blockDuration, maxMutationsPerBlock, maxSizePerMutation, initialTarget, genesisState)
		}
		
		def setTargetValidity(int targetValidity) {
			this.targetValidity = targetValidity
			return this
		}
		
		def setBlockDuration(Duration blockDuration) {
			this.blockDuration = blockDuration
			return this
		}
		
		def setMaxMutationsPerBlock(int maxMutationsPerBlock) {
			this.maxMutationsPerBlock = maxMutationsPerBlock
			return this
		}
		
		def setInitialTarget(BigInteger initialTarget) {
			this.initialTarget = initialTarget
			return this
		}
		
		def setGenesisState(IState genesisState) {
			this.genesisState = genesisState
			return this
		}

	}

}
