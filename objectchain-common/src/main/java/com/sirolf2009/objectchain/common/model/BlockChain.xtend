package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import java.util.ArrayList
import java.util.Arrays
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString
import java.util.List
import java.util.HashSet

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

	def verify(Kryo kryo, int fromBlock) {
		if(mainBranch.blocks.subList(fromBlock, mainBranch.blocks.size()).findFirst[!verify(kryo)] !== null) {
			return false
		}
		if(!hashCheck(kryo, fromBlock)) {
			return false
		}
		return true
	}

	def hashCheck(Kryo kryo, int fromBlock) {
		var prevousHash = mainBranch.blocks.get(fromBlock).hash(kryo)
		for (var i = fromBlock + 1; i < mainBranch.blocks.size(); i++) {
			if(!mainBranch.blocks.get(i).header.previousBlock.equals(prevousHash)) {
				return false
			}
		}
		return true
	}

	def branchOff(Kryo kryo, Block block) {
		val branchRoot = mainBranch.blocks.findLast[hash(kryo).equals(block.header.previousBlock)]
		sideBranches.add(new Branch(branchRoot, new ArrayList(Arrays.asList(branchRoot, block))))
	}
	
	def totalBranchLength(Branch branch) {
		return mainBranch.blocks.indexOf(branch.root) + branch.blocks.size()
	}

	def isBranchLonger(Branch branch) {
		return branch.totalBranchLength > mainBranch.blocks.size()
	}

	def promoteBranch(Branch branch) {
		val newSideBranch = new Branch(branch.root, blocks.subList(blocks.indexOf(branch.root), blocks.size()).clone)
		sideBranches.remove(branch)
		sideBranches.add(newSideBranch)
		blocks.removeAll(newSideBranch.blocks)
		blocks.addAll(branch.blocks)
	}

	def getBlocks() {
		return mainBranch.blocks
	}

	def size() {
		return blocks.size()
	}

}
