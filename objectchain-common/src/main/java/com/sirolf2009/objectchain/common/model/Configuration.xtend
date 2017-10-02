package com.sirolf2009.objectchain.common.model

import java.math.BigInteger
import java.time.Duration
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.objectchain.common.interfaces.IState

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
	
}