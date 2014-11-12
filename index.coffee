join = require('path').join
module.exports =
  Client: require join(__dirname, 'client')
  Server: require join(__dirname, 'server')
