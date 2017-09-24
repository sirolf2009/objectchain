package com.sirolf2009.objectchain.example.tracker

import com.sirolf2009.objectchain.tracker.Tracker

/**
 * Holds a list of peers in memory. When someone joins the network, they'll connect to the server and request the list.
 */
class ChatTracker extends Tracker {
	
	new(int port) {
		super(port)
	}

	def static void main(String[] args) {
		new ChatTracker(2012).start()
	}
	
}