package com.sirolf2009.objectchain.node

import com.google.gson.Gson
import io.netty.bootstrap.Bootstrap
import io.netty.bootstrap.ServerBootstrap
import io.netty.channel.ChannelInitializer
import io.netty.channel.ChannelOption
import io.netty.channel.nio.NioEventLoopGroup
import io.netty.channel.socket.SocketChannel
import io.netty.channel.socket.nio.NioServerSocketChannel
import io.netty.channel.socket.nio.NioSocketChannel
import io.netty.handler.codec.string.StringDecoder
import io.netty.handler.codec.string.StringEncoder
import io.netty.handler.logging.LogLevel
import io.netty.handler.logging.LoggingHandler

class Node {
	
	static val gson = new Gson()
	
	def static void main(String[] args) {
		println("Starting host")
		new Thread([host], "host") => [
			daemon = true
			start()
		]
		println("Connecting to tracker")
		val group = new NioEventLoopGroup()
		
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
	
	def static connectToNode(String host) {
		val group = new NioEventLoopGroup()
		try {
			val bootstrap = new Bootstrap() => [
				group(group)
				channel(NioSocketChannel)
				option(ChannelOption.TCP_NODELAY, true)
				handler(new ChannelInitializer<SocketChannel>() {
					
					override protected initChannel(SocketChannel channel) throws Exception {
						channel.pipeline().addLast(new StringDecoder())
						channel.pipeline().addLast(new StringEncoder())
						channel.pipeline().addLast(new NodeHandler(gson, [
							println('''Received from node «it»''')
						], [
							println('''Received from node «it»''')
						]))
					}
					
				})
			]
			
			println("connecting...")
			val channelFuture = bootstrap.connect(host, 12345)
			channelFuture.channel().closeFuture().sync()
		} finally {
			group.shutdownGracefully()
		}
	}
	
	def static host() {
		val bossGroup = new NioEventLoopGroup(1)
		val workerGroup = new NioEventLoopGroup()

		try {
			val bootstrap = new ServerBootstrap() => [
				group(bossGroup, workerGroup)
				channel(NioServerSocketChannel)
				option(ChannelOption.SO_BACKLOG, 100)
				handler(new LoggingHandler(LogLevel.INFO))
				childHandler(new ChannelInitializer<SocketChannel>() {

					override protected initChannel(SocketChannel channel) throws Exception {
						channel.pipeline().addLast(new StringDecoder())
						channel.pipeline().addLast(new StringEncoder())
					}

				})
			]
			val channelFuture = bootstrap.bind(12346).sync()
			channelFuture.channel().closeFuture().sync()
		} finally {
			bossGroup.shutdownGracefully()
			workerGroup.shutdownGracefully()
		}
	}
	
}