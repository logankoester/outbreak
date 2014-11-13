child_process = require 'child_process'
running = require 'is-running'
path = require 'path'
dnode = require 'dnode'
retry = require 'retry'
fs = require 'fs'
join = require('path').join
Shared = require join(__dirname, 'shared')
EventEmitter = require('events').EventEmitter

module.exports = class Client
  @include Shared

  constructor: (@options={}) ->
    @name = @options.name
    @command = @options.command
    @cwd = @options.cwd || process.cwd()
    @args = @options.args

  connect: (cb, retries = 5) ->
    if @isRunning()
      operation = retry.operation retries: retries
      operation.attempt (currentAttempt) =>
        @unsafeConnect (err, client, events) ->
          return if operation.retry(err)
          if err
            cb operation.mainError() if cb?
          else
            cb null, client, events if cb?
    else
      @cleanPidfile()
      @cleanSocket()
      @spawn => @connect(cb, retries)

  # Send a SIGINT signal to the process.
  #
  # @param [Function] cb An optional callback
  #
  # @note If the process was not spawned by this object and a callback is
  # supplied, it will be triggered immediately without waiting for the process
  # to exit.
  kill: (cb) ->
    if @child?
      @child.on 'exit', -> cb() if cb?
      @child.kill 'SIGINT'
    else
      process.kill @getPid(), 'SIGINT'
      cb() if cb?

  isRunning: ->
    pid = @getPid()
    if pid? then running @getPid() else false

  unsafeConnect: (cb) ->
    if fs.existsSync(@getSocket())
      client = dnode.connect @getSocket()
      events = @subscribe client
      cb(null, client, events)
    else
      cb new Error 'Socket not ready'

  spawn: (cb) ->
    @child = child_process.spawn @command, @args,
      detached: true
      stdio: 'ignore'
      cwd: @cwd
    @child.unref()
    cb()

  getPid: ->
    if @child? then return @child.pid
    if fs.existsSync @getPidfile()
      parseInt fs.readFileSync(@getPidfile()).toString()
    else
      null

  subscribe: (client) ->
    events = new EventEmitter
    client.on 'remote', (remote) ->
      remote.subscribe events.emit.bind(events)
    events
