#!/usr/bin/env coffee

outbreak = require require('path').join(__dirname, '..')

server = new outbreak.Server
  name: 'simple'
  remoteMethods:
    getString: (cb) -> cb 'OUTBREAK'
    triggerEvent: (event, data) ->
      server.publish event, data

setInterval ->
  n = Math.floor(Math.random() * 100)
  server.publish 'data', n
, 1000

server.connect()
