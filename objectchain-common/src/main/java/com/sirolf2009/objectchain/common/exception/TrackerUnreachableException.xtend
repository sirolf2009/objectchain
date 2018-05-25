package com.sirolf2009.objectchain.common.exception

import org.eclipse.xtend.lib.annotations.Accessors
import java.net.InetSocketAddress

@Accessors class TrackerUnreachableException extends Exception {
	
	val InetSocketAddress tracker
	
	new(InetSocketAddress tracker) {
		super('''Failed to connect to tracker «tracker»''')
		this.tracker = tracker
	}
	
	new(InetSocketAddress tracker, String message) {
		super(message)
		this.tracker = tracker
	}
	
	new(InetSocketAddress tracker, Throwable cause) {
		super('''Failed to connect to tracker «tracker»''', cause)
		this.tracker = tracker
	}
	
	new(InetSocketAddress tracker, String message, Throwable cause) {
		super(message, cause)
		this.tracker = tracker
	}
	
}