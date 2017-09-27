package com.sirolf2009.objectchain.common.exception

import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Branch
import org.eclipse.xtend.lib.annotations.Data

@Data class BranchVerificationException extends VerificationException {

	val Branch branch
	val Block blockFrom
	val Block blockTo
	
	new(Branch branch, Block blockFrom, Block blockTo, String message) {
		super(message)
		this.branch = branch
		this.blockFrom = blockFrom
		this.blockTo = blockTo
	}
	
	new(Branch branch, Block blockFrom, Block blockTo, String message, Throwable cause) {
		super(message, cause)
		this.branch = branch
		this.blockFrom = blockFrom
		this.blockTo = blockTo
	}
	
}