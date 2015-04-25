#!/usr/bin/env coffee

path = require 'path'
outbreak = require path.join(__dirname, '..')

@client = new outbreak.Client
  name: 'simple'
  command: path.resolve(__dirname, 'simple.coffee')
  args: []
  cwd: process.cwd()

@client.connect (err, client, events) =>

  client.on 'data', (data) ->
    console.log data

  client.on 'remote', (remote) ->
    remote.call 'getString', (resp) ->
      console.log resp

  events.on 'data', (n) ->
    console.log 'data: ' + n
