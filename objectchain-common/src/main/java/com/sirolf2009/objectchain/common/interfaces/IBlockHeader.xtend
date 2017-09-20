package com.sirolf2009.objectchain.common.interfaces

import java.math.BigInteger
import java.util.Date
import java.util.List

interface IBlockHeader extends IHashable {
	
	def short getVersion()
	def List<Byte> getPreviousBlock()
	def List<Byte> getMerkleRoot()
	def Date getTime()
	def BigInteger getTarget()
	def int getNonce()
	
	def isBelowTarget() {
		return new BigInteger(hash(), 16) < getTarget()
	}
	
}