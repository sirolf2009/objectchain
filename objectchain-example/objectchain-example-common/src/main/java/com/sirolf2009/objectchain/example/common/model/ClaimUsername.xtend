package com.sirolf2009.objectchain.example.common.model

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@ToString
@Accessors
@EqualsHashCode
/**
 * Claim a username.
 * The network will only allow you to claim a username that hasn't been claimed before. 
 * When you claim it, it's bound to your private key and the nodes will display this username for all the next messages you sent
 */
class ClaimUsername {
	
	var String username
	
}