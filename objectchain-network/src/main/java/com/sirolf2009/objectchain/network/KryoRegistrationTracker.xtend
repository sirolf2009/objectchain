package com.sirolf2009.objectchain.network

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.network.tracker.TrackerList
import com.sirolf2009.objectchain.network.tracker.TrackerRequest
import java.util.ArrayList
import com.sirolf2009.objectchain.network.tracker.TrackedNode

class KryoRegistrationTracker {
	
	def static register(Kryo kryo) {
		kryo.register(ArrayList)
		kryo.register(TrackerRequest)
		kryo.register(TrackerList)
		kryo.register(TrackedNode)
	}
	
}