package com.sirolf2009.objectchain.common.model

import com.google.gson.Gson
import java.util.Date
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class BlockHeader {
	
	val short version = 1 as short
	val List<Byte> previousBlock
	val List<Byte> merkleRoot
	val Date time
	val long bits
	val int nonce
	
	def hash() {
		new Gson().toJson(this).doubleHashLittleEndian()
	}
	
}