#!/usr/bin/env coffee

outbreak = require require('path').join(__dirname, '..')

server = new outbreak.Server
  name: 'simple'
  remoteMethods:
    getString: (cb) -> cb 'foo'

setInterval ->
  n = Math.floor(Math.random() * 100)
  server.publish 'data', n
, 1000

server.connect()
