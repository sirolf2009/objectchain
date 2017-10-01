package com.sirolf2009.objectchain.example.common.model

import com.sirolf2009.objectchain.common.interfaces.IState
import com.sirolf2009.objectchain.common.model.Block
import java.util.Map
import java.util.Stack
import org.eclipse.xtend.lib.annotations.Data
import java.security.PublicKey
import java.util.HashMap

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class ChatState implements IState {
	
	val Stack<String> chat
	val Map<PublicKey, String> usernames
	
	override apply(Block block) {
		val usernames = new HashMap()
		usernames.putAll(this.usernames)
		block.mutations.filter[object instanceof ClaimUsername].forEach[
			usernames.put(publicKey, (object as ClaimUsername).username)
		]
		
		val chat = new Stack<String>()
		chat.addAll(this.chat)
		block.mutations.filter[object instanceof Message].forEach[
			chat.add('''«usernames.getOrDefault(publicKey, publicKey.encoded.toHexString())»: «(object as Message).message»''')
		]
		
		return new ChatState(chat, usernames)
	}
	
}