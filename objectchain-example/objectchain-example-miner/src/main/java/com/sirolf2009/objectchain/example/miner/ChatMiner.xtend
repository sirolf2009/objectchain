package com.sirolf2009.objectchain.example.miner

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.example.node.ChatNode
import java.security.KeyPair
import java.util.List
import org.objectchain.mining.model.Miner
import org.slf4j.Logger
import com.sirolf2009.objectchain.example.common.model.ChatConfiguration

class ChatMiner extends Miner {
	
	new(List<String> trackers, int nodePort, KeyPair keys) {
		super(new ChatConfiguration(), ChatNode.chatKryo, trackers, nodePort, keys)
	}
	
	new(Logger logger, List<String> trackers, int nodePort, KeyPair keys) {
		super(logger, new ChatConfiguration(), ChatNode.chatKryo, trackers, nodePort, keys)
	}

	def static void main(String[] args) {
		val port = {
			if(args.length() > 0) {
				Integer.parseInt(args.get(0))
			} else {
				4566
			}
		}
		// trackers are hardcoded in your application, they provide the initial list of peers when a node joins the network
		new ChatMiner(#["localhost"], port, Keys.generateAssymetricPair()).start()
	}
	
}