package com.sirolf2009.objectchain.example.tests

import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.example.common.model.ClaimUsername
import com.sirolf2009.objectchain.example.common.model.Message
import com.sirolf2009.objectchain.example.miner.ChatMiner
import com.sirolf2009.objectchain.example.node.ChatNode
import com.sirolf2009.objectchain.network.node.NewBlock
import com.sirolf2009.objectchain.network.node.SyncResponse
import com.sirolf2009.objectchain.node.Node
import java.io.ByteArrayOutputStream
import java.math.BigInteger
import java.util.Date
import java.util.TreeSet
import junit.framework.Assert
import org.junit.Test

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class TestConsistency {

	@Test
	def void testChatMessage() {
		val newBlock = new NewBlock() => [
			block = new Block(new BlockHeader(#[1 as byte, 2 as byte, 3 as byte], #[1 as byte, 2 as byte, 3 as byte], new Date(), BigInteger.TEN, 0), new TreeSet(#[
				new Mutation(new Message() => [
					message = "Hello!"
				], Keys.generateAssymetricPair()),
				new Mutation(new ClaimUsername() => [
					username = "sirolf2009"
				], Keys.generateAssymetricPair())
			]))
		]
		val expected = new ChatNode(#[], -1, Keys.generateAssymetricPair()).hash(newBlock)
		println('''Expected: «expected.toHexString()»''')

		for (var i = 0; i < 100; i++) {
			val node = new ChatNode(#[], -1, Keys.generateAssymetricPair())
			val actual = node.hash(newBlock)
			println('''Node («i»/100): «actual.toHexString»''')
			Assert.assertEquals(expected, actual)
		}
		for (var i = 0; i < 100; i++) {
			val node = new ChatMiner(#[], -1, Keys.generateAssymetricPair())
			val actual = node.hash(newBlock)
			println('''Miner («i»/100): «actual.toHexString»''')
			Assert.assertEquals(expected, actual)
		}
	}

	@Test
	def void testNewBlock() {
		val newBlock = new NewBlock() => [
			block = new Block(new BlockHeader(#[1 as byte, 2 as byte, 3 as byte], #[1 as byte, 2 as byte, 3 as byte], new Date(), BigInteger.TEN, 0), new TreeSet(#[new Mutation("Hello World!", Keys.generateAssymetricPair())]))
		]
		val expected = new ChatNode(#[], -1, Keys.generateAssymetricPair()).hash(newBlock)
		println('''Expected: «expected.toHexString()»''')

		for (var i = 0; i < 100; i++) {
			val node = new ChatNode(#[], -1, Keys.generateAssymetricPair())
			val actual = node.hash(newBlock)
			println('''Node («i»/100): «actual.toHexString»''')
			Assert.assertEquals(expected, actual)
		}
		for (var i = 0; i < 100; i++) {
			val node = new ChatMiner(#[], -1, Keys.generateAssymetricPair())
			val actual = node.hash(newBlock)
			println('''Miner («i»/100): «actual.toHexString»''')
			Assert.assertEquals(expected, actual)
		}
	}

	@Test
	def void testSyncResponse() {
		val syncResponse = new SyncResponse() => [
			newBlocks = #[new Block(new BlockHeader(#[1 as byte, 2 as byte, 3 as byte], #[1 as byte, 2 as byte, 3 as byte], new Date(), BigInteger.TEN, 0), new TreeSet(#[new Mutation("Hello World!", Keys.generateAssymetricPair())]))]
		]
		val expected = new ChatNode(#[], -1, Keys.generateAssymetricPair()).hash(syncResponse)
		println('''Expected: «expected.toHexString()»''')

		for (var i = 0; i < 100; i++) {
			val node = new ChatNode(#[], -1, Keys.generateAssymetricPair())
			val actual = node.hash(syncResponse)
			println('''Node («i»/100): «actual.toHexString»''')
			Assert.assertEquals(expected, actual)
		}
		for (var i = 0; i < 100; i++) {
			val node = new ChatMiner(#[], -1, Keys.generateAssymetricPair())
			val actual = node.hash(syncResponse)
			println('''Miner («i»/100): «actual.toHexString»''')
			Assert.assertEquals(expected, actual)
		}
	}

	def hash(Node node, Object object) {
		val buffer = new ByteArrayOutputStream()
		val out = new Output(buffer)
		node.kryoPool.run [
			writeObject(out, object)
			return null
		]
		out.close()
		return buffer.toByteArray.toList()
	}

}
