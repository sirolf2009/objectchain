package com.sirolf2009.objectchain.common.exception

import com.sirolf2009.objectchain.common.model.Block
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class BlockVerificationException extends VerificationException {
	
	val Block block
	
	new(Block block, String message) {
		super(message)
		this.block = block
	}
	
	new(Block block, String message, Throwable cause) {
		super(message, cause)
		this.block = block
	}
	
}