#!/usr/bin/env coffee

path = require 'path'
outbreak = require path.join(__dirname, '..')
EventEmitter = require('events').EventEmitter

@client = new outbreak.Client
  name: 'simple'
  command: path.resolve(__dirname, 'simple.coffee')
  args: []
  cwd: __dirname

@client.connect (err, client) =>

  client.on 'data', (data) ->
    console.log data

  client.on 'remote', (remote) ->
    remote.call 'getString', (resp) ->
      console.log resp

    em = new EventEmitter
    em.on 'data', (n) ->
      console.log 'data: ' + n

    emit = em.emit.bind em
    remote.subscribe emit
