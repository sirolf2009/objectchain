package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Serializer
import com.sirolf2009.objectchain.common.model.BlockChain
import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.model.Branch
import com.sirolf2009.objectchain.common.model.Block

class SerializerBlockchain extends Serializer<BlockChain> {
	
	override read(Kryo kryo, Input input, Class<BlockChain> type) {
		val blockchain = new BlockChain()
		blockchain.mainBranch = kryo.readObject(input, Branch)
		blockchain.sideBranches.addAll(kryo.readObject(input, typeof(Branch[])))
		blockchain.orphanedBlocks.addAll(kryo.readObject(input, typeof(Block[])))
		return blockchain
	}
	
	override write(Kryo kryo, Output output, BlockChain object) {
		kryo.writeObject(output, object.mainBranch)
		kryo.writeObject(output, object.sideBranches.toArray(newArrayOfSize(object.sideBranches.size())))
		kryo.writeObject(output, object.orphanedBlocks.toArray(newArrayOfSize(object.orphanedBlocks.size())))
	}
	
}