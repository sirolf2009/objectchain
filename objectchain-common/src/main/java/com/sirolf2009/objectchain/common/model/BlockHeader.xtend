package com.sirolf2009.objectchain.common.model

import com.sirolf2009.objectchain.common.interfaces.IBlockHeader
import java.math.BigInteger
import java.util.Date
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class BlockHeader implements IBlockHeader {
	
	val short version = 1 as short
	val List<Byte> previousBlock
	val List<Byte> merkleRoot
	val Date time
	val BigInteger target
	val int nonce
	
}