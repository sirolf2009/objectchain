package com.sirolf2009.objectchain.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockChain
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Branch
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.common.serializer.SerializerBlock
import com.sirolf2009.objectchain.common.serializer.SerializerBlockHeader
import com.sirolf2009.objectchain.common.serializer.SerializerBlockchain
import com.sirolf2009.objectchain.common.serializer.SerializerBranch
import com.sirolf2009.objectchain.common.serializer.SerializerHash
import com.sirolf2009.objectchain.common.serializer.SerializerMutation
import java.math.BigInteger
import java.util.Date

class KryoRegistryCommon {

	def static register(Kryo it, Configuration configuration) {
		register(String)
		register(Date)
		register(BigInteger)
		
		register(Hash, new SerializerHash())
		register(Block, new SerializerBlock())
		register(BlockHeader, new SerializerBlockHeader())
		register(Mutation, new SerializerMutation())
		register(Branch, new SerializerBranch(configuration))
		register(BlockChain, new SerializerBlockchain())
		
		register(typeof(Mutation[]))
		register(typeof(Block[]))
		register(typeof(Branch[]))
	}

}
