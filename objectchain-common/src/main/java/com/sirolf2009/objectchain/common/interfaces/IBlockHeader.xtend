package com.sirolf2009.objectchain.common.interfaces

import java.math.BigInteger
import java.util.Date
import java.util.List
import com.esotericsoftware.kryo.Kryo
import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

interface IBlockHeader extends IHashable {
	
	def short getVersion()
	def List<Byte> getPreviousBlock()
	def List<Byte> getMerkleRoot()
	def Date getTime()
	def BigInteger getTarget()
	def int getNonce()
	
	def isBelowTarget(Kryo kryo) {
		return new BigInteger(hash(kryo).toHexString(), 16) < getTarget()
	}
	
}