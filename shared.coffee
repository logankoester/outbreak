path = require 'path'
fs = require 'fs'
mixins = require 'coffeescript-mixins'
mixins.bootstrap() # Mixes in include on Function

module.exports = class Shared
  cleanPidfile: ->
    if fs.existsSync @getPidfile()
      fs.unlinkSync @getPidfile()

  cleanSocket: ->
    if fs.existsSync @getSocket()
      fs.unlinkSync @getSocket()

  getSocket: -> path.join @cwd, 'tmp', 'socket', @name
  getPidfile: -> path.join @cwd, 'tmp', 'pid', "#{@name}.pid"
