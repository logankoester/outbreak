path = require 'path'
outbreak = require path.join(__dirname, '..')

SIMPLE_COMMAND = path.resolve(__dirname, '..', 'examples', 'simple.coffee')

describe 'A connected client named "simple"', ->
  @timeout 5000

  before (done) ->
    @client = new outbreak.Client
      name: 'simple'
      command: SIMPLE_COMMAND
      args: []
      cwd: __dirname

    @client.connect (err, client, events) =>
      @events = events
      client.end()
      done()

  it 'should be running', ->
    @client.isRunning().should.be.true

  it 'should set a pid', ->
    @client.getPid().should.be.above 1

  it 'should write a pidfile',  ->
    @client.getPidfile().should.be.a.path()

  describe 'rpc', ->
    it 'can call a remote method', (done) ->
      @client.connect (err, client, events) ->
        client.on 'remote', (remote) ->
          remote.call 'getString', (str) ->
            str.should.equal 'OUTBREAK'
            client.end()
            done()

  describe 'events', ->
    it 'can listen for remote events', (done) ->
      @client.connect (err, client, events) ->
        events.on 'someEvent', (data) ->
          data.should.equal 'someData'
          client.end()
          done()
        client.on 'remote', (remote) ->
          remote.call 'triggerEvent', 'someEvent', 'someData'

  describe 'A second client named "simple"', ->
    before (done) ->
      @client2 = new outbreak.Client
        name: 'simple'
        command: SIMPLE_COMMAND
        args: []
        cwd: __dirname

      @client2.connect (err, client, events) =>
        client.end()
        done()

    it 'should connect to the existing process', ->
      @client2.getPid().should.equal(@client.getPid())

    describe 'rpc', ->
      it 'can call a remote method', (done) ->
        @client2.connect (err, client, events) ->
          client.on 'remote', (remote) ->
            remote.call 'getString', (str) ->
              str.should.equal('OUTBREAK')
              client.end()
              done()

  describe 'killed', ->
    before (done) -> @client.kill done

    it 'should not be running', ->
      @client.isRunning().should.be.false

    it 'should unlink the pidfile',  ->
      @client.getPidfile().should.not.be.a.path()

    it 'should unlink the socket',  ->
      @client.getSocket().should.not.be.a.path()
