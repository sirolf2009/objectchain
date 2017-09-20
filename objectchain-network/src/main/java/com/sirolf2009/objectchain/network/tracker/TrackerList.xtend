package com.sirolf2009.objectchain.network.tracker

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@ToString
@Accessors
@EqualsHashCode
class TrackerList {
	
	var List<TrackedNode> tracked 
	
}