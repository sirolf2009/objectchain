# Example Project

This project serves as an example project for the object chain. It's a chat room, where nodes can submit chat messages and claim usernames.
It follows the same project structure as the Objectchain project, except for the tests projects, which defines some scenario's where multiple nodes/miners are spawned to see how they communicate with one another.

## Magic
The *vast* majority of the magic happens in the [Node class](https://github.com/sirolf2009/objectchain/blob/master/objectchain-example/objectchain-example-node/src/main/java/com/sirolf2009/objectchain/example/node/ChatNode.xtend) with the interesting parts being:
```xtend
	/** When we launch the application, we first synchronise to download any missing data. After sync we start running our chat */
	override onSynchronised() {
		new Thread [
			log.info("Initialized, running chat...")
			val scanner = new Scanner(System.in)
			while(true) {
				val line = scanner.nextLine()

				if(line.startsWith("/")) {
					if(line.startsWith("/claim")) {
						val claim = new ClaimUsername() => [
							username = line.replaceFirst("/claim", "").trim()
						]
						// Submit mutation broadcasts something to the other nodes in the network. 
						// These are automatically signed by your keys provided in the constructor of this class
						// And will eventually be included in the blockchain
						submitMutation(claim)
					} else if(line.startsWith("/help")) {
						println("Commands:")
						println("/claim <username>		Claim a username")
					}
				} else {
					val message = new Message() => [
						message = line
					]
					//Same as the submit mutation above, except this one submits a chat message. The other one submits a claim to an username
					submitMutation(message)
				}
			}
		].start()
	}
	
	/**
	 * This is called whenever a new mutation is broadcasted. We check if we consider it valid. If it is, it gets saved and propagated further to the network
	 */
	override isValid(Mutation mutation) {
		//If someone claims a username, make sure it's not been claimed by someone else
		if(mutation.object instanceof ClaimUsername) {
			val claim = mutation.object as ClaimUsername
			val state = blockchain.mainBranch.lastState as ChatState
			return !state.usernames.values.contains(claim.username)
		}
		return true
	}
	
	/**
	 * This is called whenever a block is added to the blockchain. We retrieve its state to see wich messages were included in the block.
	 * See {@link ChatState} for more 
	 */
	override onBranchExpanded() {
		val lastState = blockchain.mainBranch.lastState as ChatState
		println(lastState.newChat.join("\n"))
	}
	
	/**
	 * Our instance of kryo. Note that this is a supplier, because we need a kryo instance for every thread that uses kryo.
	 * We only register our own objects.
	 */
	def static getChatKryo() {
		return new Kryo() => [
			register(Message)
			register(ClaimUsername)
		]
	}
```
