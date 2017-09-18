package com.sirolf2009.objectchain.tracker

import com.google.gson.Gson
import io.netty.bootstrap.ServerBootstrap
import io.netty.channel.ChannelInitializer
import io.netty.channel.ChannelOption
import io.netty.channel.nio.NioEventLoopGroup
import io.netty.channel.socket.SocketChannel
import io.netty.channel.socket.nio.NioServerSocketChannel
import io.netty.handler.codec.string.StringDecoder
import io.netty.handler.codec.string.StringEncoder
import io.netty.handler.logging.LogLevel
import io.netty.handler.logging.LoggingHandler
import java.util.TreeSet

class Tracker {

	def static void main(String[] args) {
		val bossGroup = new NioEventLoopGroup(1)
		val workerGroup = new NioEventLoopGroup()

		val ips = new TreeSet()
		val gson = new Gson()

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
						channel.pipeline.addLast(new TrackerHandler(ips, gson))
					}

				})
			]
			val channelFuture = bootstrap.bind(12345).sync()
			channelFuture.channel().closeFuture().sync()
		} finally {
			bossGroup.shutdownGracefully()
			workerGroup.shutdownGracefully()
		}
	}

}
