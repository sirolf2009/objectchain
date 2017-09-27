package com.sirolf2009.objectchain.common.model

import com.esotericsoftware.kryo.Kryo
import java.math.BigInteger
import java.util.ArrayList
import java.util.Arrays
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

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
	
	def shouldRetarget(int targetValidity) {
		return shouldRetarget(targetValidity, blocks.get(blocks.size()-1))
	}
	
	def shouldRetarget(int targetValidity, Block block) {
		return (blocks.indexOf(block)+1) % targetValidity == 0
	}
	
	def getNewTarget(int targetValidity, long blockDuration) {
		val blocksSinceLastRetarget = blocks.get(blocks.size() - targetValidity)
		val previous = blocks.get(blocks.size()-1)
		val timeTaken = previous.header.time.time - blocksSinceLastRetarget.header.time.time
		return previous.header.target.getNewTarget(targetValidity, blockDuration, timeTaken)
	}
	
	def static getNewTarget(BigInteger currentTarget, int targetValidity, long blockDuration, long retargetDuration) {
		println("shouldTake="+(blockDuration.doubleValue*targetValidity.doubleValue)/1000)
		println("reality   ="+retargetDuration/1000)
		println(((blockDuration.doubleValue*targetValidity.doubleValue) / retargetDuration.doubleValue))
		println(((blockDuration.doubleValue*targetValidity.doubleValue) / retargetDuration.doubleValue).longValue)
		return currentTarget.multiply(BigInteger.valueOf(((blockDuration.doubleValue*targetValidity.doubleValue) / retargetDuration.doubleValue).longValue))
	}

	def getBlocks() {
		return mainBranch.blocks
	}

	def size() {
		return blocks.size()
	}

}
