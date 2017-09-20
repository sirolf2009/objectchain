package com.sirolf2009.objectchain.common.model

import com.google.gson.Gson
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class Block {
	
	val BlockHeader header
	val List<Transaction> transactions
	
	def hash() {
		new Gson().toJson(this).doubleHashLittleEndian()
	}
	
}