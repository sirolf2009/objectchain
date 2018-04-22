package com.sirolf2009.objectchain.common

import com.sirolf2009.objectchain.common.crypto.Hashing
import java.util.ArrayList
import java.util.List
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Mutation
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.toHexString
import java.util.TreeSet
import com.sirolf2009.objectchain.common.model.Hash

class MerkleTree {
	
	static val log = LoggerFactory.getLogger(MerkleTree)
	
	def public static Hash merkleTreeMutations(Kryo kryo, TreeSet<Mutation> hashes) {
		return new Hash(merkleTree(hashes.map[hash(kryo).getBytes()].toList()))
	}
	
	def public static String merkleTreeHex(List<String> hashes) {
		return Hashing.toHexString(merkleTree(hashes.map[Hashing.toByteArray(it)]))
	}

	def public static List<Byte> merkleTree(List<List<Byte>> hashes) {
		log.debug(hashes.map[toHexString].join(", "))
		if(hashes.size() == 0) {
			throw new IllegalArgumentException("Cannot merkle tree an empty list")
		}
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
