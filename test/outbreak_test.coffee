path = require 'path'
outbreak = require path.join(__dirname, '..')

SIMPLE_COMMAND = path.resolve(__dirname, '..', 'examples', 'simple.coffee')

describe 'A connected client named "simple"', ->
  before (done) ->
    @client = new outbreak.Client
      name: 'simple'
      command: SIMPLE_COMMAND
      args: []
      cwd: __dirname

    @client.connect (err, client) =>
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
      @client.connect (err, client) ->
        client.on 'remote', (remote) ->
          remote.getString (str) ->
            str.should.equal('foo')
            client.end()
            done()

  describe 'A second client named "simple"', ->
    before (done) ->
      @client2 = new outbreak.Client
        name: 'simple'
        command: SIMPLE_COMMAND
        args: []
        cwd: __dirname

      @client2.connect (err, client) =>
        client.end()
        done()

    it 'should connect to the existing process', ->
      @client2.getPid().should.equal(@client.getPid())

    describe 'rpc', ->
      it 'can call a remote method', (done) ->
        @client2.connect (err, client) ->
          client.on 'remote', (remote) ->
            remote.getString (str) ->
              str.should.equal('foo')
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
