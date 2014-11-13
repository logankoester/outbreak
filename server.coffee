path = require 'path'
dnode = require 'dnode'
fs = require 'fs'
join = require('path').join
Shared = require join(__dirname, 'shared')
Hash = require 'hashish'

module.exports = class Server
  @include Shared

  @subscriptions = {}

  constructor: (@options={}) ->
    @name = @options.name
    @remoteMethods = @options.remoteMethods
    @cwd = @options.cwd || process.cwd()

  connect: (cb) ->
    @setPidfile (err) =>
      if err then throw err
      @initSignals()
      @initRPC()
      @socket = @rpc.listen @getSocket()
      cb() if cb?

  setPidfile: (cb) ->
    fs.writeFile @getPidfile(), process.pid, cb

  initSignals: ->
    process.on 'SIGINT', -> process.exit()
    process.on 'exit', =>
      @cleanPidfile()
      @cleanSocket()

  initRPC: ->
    subs = {}
    self = @
    @rpc = dnode (client, conn) ->
      @call = (method, args) ->
        self.remoteMethods[method](args)
      @subscribe = (emit) ->
        Server.subscriptions[conn.id] = emit
        conn.on 'end', => delete Server.subscriptions[conn.id]

  publish: ->
    args = arguments
    Hash(Server.subscriptions).forEach (emit) ->
      emit.apply emit, args
