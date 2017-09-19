package com.sirolf2009.objectchain.common.model

import org.eclipse.xtend.lib.annotations.Data

@Data class Transaction<T> {
	
	val short version = 1 as short
	val short objectID
	val T object
	val String signature
	val String key
	
}