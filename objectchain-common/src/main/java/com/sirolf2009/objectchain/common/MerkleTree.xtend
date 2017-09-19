package com.sirolf2009.objectchain.common

import java.util.List
import java.util.ArrayList

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class MerkleTree {

	def public static String merkleTree(List<String> hashes) {
		if(hashes.size() == 1) {
			return hashes.get(0)
		}
		val newHashes = new ArrayList()
		for (var i = 0; i < hashes.length(); i += 2) {
			if(i == hashes.length() - 1) {
				newHashes.add((hashes.get(i) + hashes.get(i)).doubleHash())
			} else {
				newHashes.add((hashes.get(i) + hashes.get(i + 1)).doubleHash())
			}
		}
		return merkleTree(newHashes)
	}

}
