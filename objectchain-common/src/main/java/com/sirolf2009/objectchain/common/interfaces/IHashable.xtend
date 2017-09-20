package com.sirolf2009.objectchain.common.interfaces

import com.google.gson.Gson

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

interface IHashable {
	
	def hash() {
		new Gson().toJson(this).doubleHash()
	}
	
}