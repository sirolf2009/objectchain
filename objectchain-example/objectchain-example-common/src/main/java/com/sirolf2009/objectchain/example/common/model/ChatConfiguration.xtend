package com.sirolf2009.objectchain.example.common.model

import com.sirolf2009.objectchain.common.model.Configuration
import java.time.Duration

class ChatConfiguration extends Configuration {
	
	new() {
		super(8, Duration.ofMinutes(1), 512, 512)
	}
	
}