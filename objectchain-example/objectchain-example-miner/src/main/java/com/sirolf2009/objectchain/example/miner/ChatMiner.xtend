package com.sirolf2009.objectchain.example.miner

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.example.common.model.ChatConfiguration
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.mining.model.Miner
import java.security.KeyPair
import java.util.List
import org.slf4j.Logger
import com.sirolf2009.objectchain.example.common.model.ChatState
import java.util.Stack
import java.util.HashMap

class ChatMiner extends Miner {
	
	new(List<String> trackers, int nodePort, KeyPair keys) {
		super(new ChatConfiguration(), [ChatNode.chatKryo], trackers, nodePort, keys)
	}
	
	new(Logger logger, List<String> trackers, int nodePort, KeyPair keys) {
		super(logger, new ChatConfiguration(), [ChatNode.chatKryo], trackers, nodePort, keys)
	}
	
	override getOriginalState() {
		return new ChatState(new Stack(), new HashMap())
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