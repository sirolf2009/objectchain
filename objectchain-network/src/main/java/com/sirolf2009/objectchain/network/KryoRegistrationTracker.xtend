package com.sirolf2009.objectchain.network

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.network.tracker.TrackerList
import java.util.ArrayList
import com.sirolf2009.objectchain.network.tracker.TrackedNode
import com.sirolf2009.objectchain.network.tracker.TrackMe
import com.sirolf2009.objectchain.network.tracker.UntrackMe
import com.sirolf2009.objectchain.network.tracker.TrackerRequest

class KryoRegistrationTracker {
	
	def static register(Kryo kryo) {
		kryo.register(ArrayList)
		kryo.register(TrackMe)
		kryo.register(UntrackMe)
		kryo.register(TrackerRequest)
		kryo.register(TrackerList)
		kryo.register(TrackedNode)
	}
	
}