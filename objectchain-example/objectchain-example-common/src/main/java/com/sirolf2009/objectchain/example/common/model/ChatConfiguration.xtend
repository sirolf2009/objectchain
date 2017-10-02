package com.sirolf2009.objectchain.example.common.model

import com.sirolf2009.objectchain.common.model.Configuration
import java.math.BigInteger
import java.time.Duration
import java.util.ArrayList
import java.util.HashMap
import java.util.Stack

class ChatConfiguration extends Configuration {
	
	new() {
		super(8, Duration.ofMinutes(1), 512, 512, new BigInteger("000044FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16), new ChatState(new ArrayList(), new Stack(), new HashMap()))
	}
	
}