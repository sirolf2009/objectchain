[![Build Status](https://travis-ci.org/sirolf2009/objectchain.svg?branch=master)](https://travis-ci.org/sirolf2009/objectchain)
# Objectchain

Objectchain is a framework for creating peer-to-peer blockchains. It is written in Eclipse Xtend and therefore compiles to the JVM. It is inspired by, but not a complete replica of the Bitcoin Blockchain. The aim of the project is to provide all the structure of the blockchain, so that users would only need to implement the "rules" and the models of the application. 

Models must Kryo compatible and would be something like:
* BTC is a number that has a public key, a value, an input Transaction and an Output transaction
* A Transaction is a public key (sender), another public key (receiver) and a collection of BTC

A rule would be something like, if Alice submits a Transaction
* The transaction must be signed by the private key that corresponds to the public key of the sender
* The BTC's of the transaction must all have no output
* If all the rules resolve to true, this transaction becomes the output of all the included BTC

Note that while I've given a Bitcoin example, this system is not limited to cryptocurrencies. If you would like to make, for instance, a file sharing system then that would still be possible. The models and rules would simply need to be defined differently.

## Maven
```xml
<dependency>
    <groupId>com.sirolf2009</groupId>
    <artifactId>objectchain</artifactId>
    <version>0.0.1</version>
</dependency>
```

## Documentation

I personally don't believe in documentation. If the code isn't self-explanatory, I'd rather have you open an issue, describing the piece of code that you can't understand and I'll see about re-writing it.

In this spirit, I do include an example project, which represents a simple chat room built on the objectchain. You can find it [here](https://github.com/sirolf2009/objectchain/tree/master/objectchain-example) and it would be the best place for you to start learning. If this scares you, don't be scared. It only consists of 4 classes that actually do anything (and 2 of those just call a constructor), plus a bunch of model classes.

## Dependencies

This framework only has two dependencies. Namely https://github.com/EsotericSoftware/kryo and https://github.com/EsotericSoftware/kryonet.
They are used for the serializing and networking.

## Module Overview

### Common

* Hashing
* Cryptography
* Models
* Standards & Protocols

### Network

* Communication protocol between senders and receivers
  * Turns the models defined in common into bytes and vice versa
  * Defines a small framework to turn the custom models from the application into bytes and vice versa

### Node

A node in the blockchain network. Receives transaction updates and block updates and propagates them further to other peers

### Tracker

A node in the blockchain network that keeps track of connected nodes. When a new node joins, it will probably connect to a tracker to receive a list of peers to communicate with

### Mining

A node in the blockchain network that mines new blocks 
