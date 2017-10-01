package com.sirolf2009.objectchain.mining.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.interfaces.IBlockHeader
import com.sirolf2009.objectchain.common.model.BlockHeader
import java.math.BigInteger
import java.util.Date
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

/**
 * A mutable version of {@link BlockHeader} to reduce memory usage when mining
 */
@Accessors
@EqualsHashCode
@ToString
class BlockHeaderMutable implements IBlockHeader {
	
	val short version = 1 as short
	val List<Byte> previousBlock
	var List<Byte> merkleRoot
	var Date time = new Date()
	val BigInteger target
	var int nonce
	
	def immutable() {
		return new BlockHeader(previousBlock, merkleRoot, time, target, nonce)
	}
	
	override hash(Kryo kryo) {
		return immutable().hash(kryo)
	}
	
}