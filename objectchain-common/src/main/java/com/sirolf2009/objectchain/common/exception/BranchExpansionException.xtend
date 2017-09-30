package com.sirolf2009.objectchain.common.exception

import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Branch
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class BranchExpansionException extends Exception {
	
	val Branch branch
	val Block newBlock
	
	new(Branch branch, Block newBlock, String message) {
		super(message)
		this.branch = branch
		this.newBlock = newBlock
	}
	
	new(Branch branch, Block newBlock, String message, Throwable cause) {
		super(message, cause)
		this.branch = branch
		this.newBlock = newBlock
	}
	
}