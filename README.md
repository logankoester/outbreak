# Outbreak

> Service process management with dnode rpc 

## Overview

The **outbreak** module makes it easy to break a monolithic program out to one or more spawned processes, and then either continue communicating with them actively or simply exit and allow control to be picked up again the next time your program runs (or even by another program).

See the `examples/` directory to see how **outbreak** can be used.

## Implementing a server

To implement a service process using outbreak, simply create a new instance of `outbreak.Server` and call it's `connect()` method.

The constructor expects a configuration map with two options: `name` (a unique identifier), and `remoteMethods`, which exposes any methods you want `outbreak` clients to be able to call.

```coffeescript
outbreak = require 'outbreak'
server = new outbreak.Server
  name: 'simple'
    remoteMethods:
      getString: (cb) -> cb 'foo'
```

When `connect()` is called, a pidfile and a socket will be created (using the `name` option that was passed to the constructor). When your service catches `SIGINT`, these files will be unlinked and the process will exit.

You can also use publish data with events to all connected clients.

```coffeescript
setInterval ->
  n = Math.floor(Math.random() * 100)
  server.publish 'data', n
, 1000

server.connect()
```

## License

Copyright (c) 2014-2015 Logan Koester
Licensed under the MIT license.
