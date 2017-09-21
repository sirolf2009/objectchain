package com.sirolf2009.objectchain.common

import com.sirolf2009.objectchain.common.crypto.Hashing
import com.sirolf2009.objectchain.common.model.Transaction
import java.util.ArrayList
import java.util.List
import com.esotericsoftware.kryo.Kryo

class MerkleTree {
	
	def public static List<Byte> merkleTreeTransactions(Kryo kryo, List<Transaction> hashes) {
		return merkleTree(hashes.map[hash(kryo)])
	}
	
	def public static String merkleTreeHex(List<String> hashes) {
		return Hashing.toHexString(merkleTree(hashes.map[Hashing.toByteArray(it)]))
	}

	def public static List<Byte> merkleTree(List<List<Byte>> hashes) {
		if(hashes.size() == 1) {
			return hashes.get(0)
		}
		val newHashes = new ArrayList()
		for (var i = 0; i < hashes.length(); i += 2) {
			val left = hashes.get(i)
			val right = hashes.get(Math.min(hashes.size() -1, i+1))
			newHashes.add(hash(left, right))
		}
		return merkleTree(newHashes)
	}
	
	def public static List<Byte> hash(List<Byte> left, List<Byte> right) {
		return Hashing.doubleHash(left.reverseView(), right.reverseView()).reverse()
	}

}
