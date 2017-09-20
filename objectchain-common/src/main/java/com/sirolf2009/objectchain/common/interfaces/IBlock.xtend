package com.sirolf2009.objectchain.common.interfaces

import com.sirolf2009.objectchain.common.model.Transaction
import java.util.List

interface IBlock extends IHashable {
	
	def IBlockHeader getHeader()
	def List<Transaction> getTransactions()
	
}