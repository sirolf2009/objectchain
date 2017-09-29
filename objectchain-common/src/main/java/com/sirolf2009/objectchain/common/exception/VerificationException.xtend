package com.sirolf2009.objectchain.common.exception

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class VerificationException extends Exception{
	
	new(String message) {
		super(message)
	}
	
	new(String message, Throwable cause) {
		super(message, cause)
	}
	
}