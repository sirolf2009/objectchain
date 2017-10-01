package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import java.util.ArrayList
import java.util.Arrays
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString
import com.sirolf2009.objectchain.common.exception.BranchVerificationException

@ToString
@Accessors
@EqualsHashCode
class BlockChain {

	var Branch mainBranch
	val List<Branch> sideBranches

	val Set<Block> orphanedBlocks
	
	new() {
		this(new ArrayList(), new HashSet())
	}
	
	new(List<Branch> sideBranches, Set<Block> orphanedBlocks) {
		this.sideBranches = sideBranches
		this.orphanedBlocks = orphanedBlocks
	}

	def verify(Kryo kryo, Configuration configuration) throws BranchVerificationException {
		mainBranch.verify(kryo, configuration)
	}
	
	def branchOff(Kryo kryo, Block block) {
		val branchRoot = mainBranch.blocks.findLast[hash(kryo).equals(block.header.previousBlock)]
		sideBranches.add(new Branch(branchRoot, new ArrayList(Arrays.asList(branchRoot, block)), new ArrayList()))
	}
	
	def totalBranchLength(Branch branch) {
		return mainBranch.blocks.indexOf(branch.root) + branch.blocks.size()
	}

	def isBranchLonger(Branch branch) {
		return branch.totalBranchLength > mainBranch.blocks.size()
	}

	def promoteBranch(Branch branch) {
		val newSideBranch = new Branch(branch.root, mainBranch.blocks.subList(mainBranch.blocks.indexOf(branch.root), mainBranch.size()).clone, new ArrayList())
		sideBranches.remove(branch)
		sideBranches.add(newSideBranch)
		mainBranch.blocks.removeAll(newSideBranch.blocks)
		mainBranch.blocks.addAll(branch.blocks)
	}

}
