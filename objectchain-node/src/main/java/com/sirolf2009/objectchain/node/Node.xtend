package com.sirolf2009.objectchain.node

import com.google.gson.Gson
import io.netty.bootstrap.Bootstrap
import io.netty.channel.ChannelInitializer
import io.netty.channel.ChannelOption
import io.netty.channel.nio.NioEventLoopGroup
import io.netty.channel.socket.SocketChannel
import io.netty.channel.socket.nio.NioSocketChannel
import io.netty.handler.codec.string.StringDecoder
import io.netty.handler.codec.string.StringEncoder

class Node {
	
	def static void main(String[] args) {
		val group = new NioEventLoopGroup()
		
		val gson = new Gson()
		
		try {
			val bootstrap = new Bootstrap() => [
				group(group)
				channel(NioSocketChannel)
				option(ChannelOption.TCP_NODELAY, true)
				handler(new ChannelInitializer<SocketChannel>() {
					
					override protected initChannel(SocketChannel channel) throws Exception {
						channel.pipeline().addLast(new StringDecoder())
						channel.pipeline().addLast(new StringEncoder())
						channel.pipeline().addLast(new TrackerHandlerClient(gson, [
							println('''Received from tracker «it»''')
						]))
					}
					
				})
			]
			
			println("connecting...")
			val channelFuture = bootstrap.connect("localhost", 12345)
			channelFuture.channel().closeFuture().sync()
		} finally {
			group.shutdownGracefully()
		}
	}
	
}