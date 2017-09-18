package com.sirolf2009.objectchain.node

import com.google.gson.Gson
import com.google.gson.JsonSyntaxException
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Transaction
import io.netty.channel.ChannelHandlerContext
import io.netty.channel.SimpleChannelInboundHandler
import java.net.InetSocketAddress
import java.util.function.Consumer
import org.eclipse.xtend.lib.annotations.Data

@Data class NodeHandler extends SimpleChannelInboundHandler<String> {
	
	val Gson gson
	val Consumer<Transaction> onTransactionReceived
	val Consumer<Block> onBlockReceived
	
	override channelActive(ChannelHandlerContext ctx) throws Exception {
		println("Connected to node "+(ctx.channel.remoteAddress as InetSocketAddress).address.hostAddress)
	}
	
	override protected channelRead0(ChannelHandlerContext ctx, String msg) throws Exception {
		try {
			onTransactionReceived.accept(gson.fromJson(msg, Transaction))
		} catch(JsonSyntaxException e) {
		}
		try {
			onBlockReceived.accept(gson.fromJson(msg, Block))
		} catch(JsonSyntaxException e) {
		}
	}
	
}