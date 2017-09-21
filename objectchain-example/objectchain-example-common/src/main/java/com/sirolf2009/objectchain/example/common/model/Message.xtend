package com.sirolf2009.objectchain.example.common.model

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString
import org.eclipse.xtend.lib.annotations.EqualsHashCode

@ToString
@Accessors
@EqualsHashCode
/**
 * Holds a chat message that someone has said. 
 * Note that it does not include a username. Refer to {@link ClaimUsername} for more information on usernames
 */
class Message {
	
	var String message
	
}