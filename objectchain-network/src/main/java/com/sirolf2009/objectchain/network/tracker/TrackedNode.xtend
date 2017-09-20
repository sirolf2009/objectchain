package com.sirolf2009.objectchain.network.tracker

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@ToString
@Accessors
@EqualsHashCode
class TrackedNode implements Comparable<TrackedNode> {

	var String host
	var int port
	
	override compareTo(TrackedNode other) {
		return (host+":"+port).compareTo(other.host+":"+other.port)
	}
	
}