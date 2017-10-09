package com.sirolf2009.objectchain.common.model

import com.sirolf2009.objectchain.common.interfaces.IState
import org.eclipse.xtend.lib.annotations.Data
import com.esotericsoftware.kryo.Kryo

@Data class TestState implements IState {
	
	val int count
	
	override apply(Kryo kryo, Block block) {
		return new TestState(count+1)
	}
	
}