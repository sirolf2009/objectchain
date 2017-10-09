package com.sirolf2009.objectchain.common

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.model.BlockChain
import com.sirolf2009.objectchain.common.model.Configuration
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.zip.GZIPInputStream
import java.util.zip.GZIPOutputStream

class BlockchainPersistence {

	def static save(Kryo kryo, BlockChain blockchain, File file) {
		val out = new GZIPOutputStream(new FileOutputStream(file))
		val output = new Output(out)
		kryo.writeObject(output, blockchain)
		output.close() 
		out.close()
	}
	
	def static load(Kryo kryo, Configuration configuration, File file) {
		val in = new GZIPInputStream(new FileInputStream(file))
		val input = new Input(in)
		val blockchain = kryo.readObject(input, BlockChain)
		input.close()
		in.close()
		blockchain.verify(kryo, configuration)
		blockchain.mainBranch.calculateStates(kryo)
		blockchain.sideBranches.forEach[
			val previousHash = blocks.get(0).header.previousBlock
			val branchOff = blockchain.mainBranch.blocks.indexOf(blockchain.mainBranch.blocks.findFirst[hash(kryo).equals(previousHash)])
			val state = blockchain.mainBranch.states.get(branchOff)
			calculateStates(kryo, state)
		]
		return blockchain
	}
	
}