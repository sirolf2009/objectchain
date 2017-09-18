package com.sirolf2009.objectchain.tracker

import com.google.gson.Gson
import io.netty.channel.ChannelHandlerContext
import io.netty.channel.SimpleChannelInboundHandler
import java.net.InetSocketAddress
import java.util.Collection
import org.eclipse.xtend.lib.annotations.Data

@Data class TrackerHandler extends SimpleChannelInboundHandler<String> {
	
	val Collection<String> ips
	val Gson gson
	
	override channelActive(ChannelHandlerContext ctx) throws Exception {
		val ip = (ctx.channel.remoteAddress as InetSocketAddress).address.hostAddress
		println('''Tracking «ip»''')
		ctx.writeAndFlush(gson.toJson(ips))
		ips.add(ip)
	}
	
	override channelInactive(ChannelHandlerContext ctx) throws Exception {
		val ip = (ctx.channel.remoteAddress as InetSocketAddress).address.hostAddress
		println('''Untracking «ip»''')
		ips.remove(ip)
	}
	
	override protected channelRead0(ChannelHandlerContext ctx, String msg) throws Exception {
	}
	
	override exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
		cause.printStackTrace()
		ctx.close()
	}
	
}