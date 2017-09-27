package com.sirolf2009.objectchain.common.exception

import com.sirolf2009.objectchain.common.model.Mutation

class MutationVerificationException extends VerificationException {
	
	val Mutation mutation
	
	new(Mutation mutation, String message) {
		super(message)
		this.mutation = mutation
	}
	
	new(Mutation mutation, String message, Throwable cause) {
		super(message, cause)
		this.mutation = mutation
	}
	
}