package com.sirolf2009.objectchain.common.model

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import java.util.Date

@Data class BlockHeader {
	
	val short version = 1 as short
	val List<Byte> previousBlock
	val List<Byte> merkleRoot
	val Date time
	val List<Byte> bits
	val int nonce
	
}