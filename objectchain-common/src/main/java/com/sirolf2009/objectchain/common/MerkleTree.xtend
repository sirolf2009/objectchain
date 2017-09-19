package com.sirolf2009.objectchain.common

import com.sirolf2009.objectchain.common.crypto.Hashing
import java.util.ArrayList
import java.util.List

class MerkleTree {
	
	def public static String merkleTreeHex(List<String> hashes) {
		return Hashing.toHexString(merkleTree(hashes.map[Hashing.toByteArray(it)]))
	}

	def public static List<Byte> merkleTree(List<List<Byte>> hashes) {
		if(hashes.size() == 1) {
			return hashes.get(0)
		}
		val newHashes = new ArrayList()
		for (var i = 0; i < hashes.length(); i += 2) {
			if(i == hashes.length() - 1) {
				newHashes.add(Hashing.doubleHash(hashes.get(i).reverseView(), hashes.get(i).reverseView()).reverseView())
			} else {
				newHashes.add(Hashing.doubleHash(hashes.get(i).reverseView(), hashes.get(i+1).reverseView()).reverseView())
			}
		}
		return merkleTree(newHashes)
	}
	
	def public static hash(List<Byte> a, List<Byte> b) {
	}

}
