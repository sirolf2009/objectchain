package com.sirolf2009.objectchain.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.Serializer
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Branch
import com.sirolf2009.objectchain.common.model.Configuration
import java.util.ArrayList
import java.util.Arrays
import org.eclipse.xtend.lib.annotations.Data

@Data class SerializerBranch extends Serializer<Branch> {
	
	val Configuration configuration
	
	override read(Kryo kryo, Input input, Class<Branch> type) {
		val blocks = kryo.readObject(input, typeof(Block[]))
		val branch = new Branch(blocks.get(0), new ArrayList(Arrays.asList(blocks.get(0))), new ArrayList(Arrays.asList(configuration.genesisState)))
		blocks.stream.skip(1).forEach[
			branch.add(kryo, configuration, it)
		]
		return branch
	}
	
	override write(Kryo kryo, Output output, Branch object) {
		kryo.writeObject(output, object.blocks.toArray(newArrayList(object.blocks.size())))
	}
	
}