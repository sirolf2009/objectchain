package com.sirolf2009.objectchain.common.model

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.objectchain.common.crypto.Hashing
import java.math.BigInteger

@Data class Hash {
	
	val List<Byte> bytes
	
	override toString() {
		return Hashing.toHexString(bytes)
	}
	
	def toBigInteger() {
		return new BigInteger(Hashing.toHexString(bytes), 16)
	}
	
}