package com.sirolf2009.objectchain.node

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.netty.channel.ChannelHandlerContext
import io.netty.channel.SimpleChannelInboundHandler
import java.util.List
import java.util.function.Consumer
import org.eclipse.xtend.lib.annotations.Data

@Data class TrackerHandlerClient extends SimpleChannelInboundHandler<String> {
	
	val listType = new TypeToken<List<String>>() {}.getType();
	val Gson gson
	val Consumer<List<String>> onTrackersReceived
	
	override protected channelRead0(ChannelHandlerContext ctx, String msg) throws Exception {
		onTrackersReceived.accept(gson.fromJson(msg, listType))
	}
	
	override exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
		cause.printStackTrace()
		ctx.close()
	}
	
}