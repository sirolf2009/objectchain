package com.sirolf2009.objectchain.common.interfaces

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Hash
import java.math.BigInteger
import java.util.Date

interface IBlockHeader extends IHashable {
	
	def short getVersion()
	def Hash getPreviousBlock()
	def Hash getMerkleRoot()
	def Date getTime()
	def BigInteger getTarget()
	def int getNonce()
	
	def isBelowTarget(Kryo kryo) {
		return hash(kryo).toBigInteger() < getTarget()
	}
	
}