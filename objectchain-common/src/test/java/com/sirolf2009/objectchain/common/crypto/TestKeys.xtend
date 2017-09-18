package com.sirolf2009.objectchain.common.crypto

import java.io.File

class TestKeys {
	
	public static val alicePrivate = Keys.readPrivateKeyFromFile(new File("src/test/resources/alice.private"))
	public static val alicePublic = Keys.readPrivateKeyFromFile(new File("src/test/resources/alice.private"))
	public static val bobPrivate = Keys.readPrivateKeyFromFile(new File("src/test/resources/alice.private"))
	public static val bobPublic = Keys.readPrivateKeyFromFile(new File("src/test/resources/alice.private"))
	
}