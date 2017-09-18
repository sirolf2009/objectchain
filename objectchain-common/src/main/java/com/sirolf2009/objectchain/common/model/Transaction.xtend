package com.sirolf2009.objectchain.common.model

import org.eclipse.xtend.lib.annotations.Data

@Data class Transaction {
	
	val short version = 1 as short
	val short objectID
	val String object
	val String signature
	val String key
	
}