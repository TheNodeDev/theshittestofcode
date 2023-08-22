const WebSocket = require('ws');

// Create a WebSocket server instance
const server = new WebSocket.Server({ noServer: true });

// Store connected clients by path
const clientsByPath = {};

const savesByPath = {}

// Handle WebSocket upgrade requests
server.on('connection', (client, request) => {
  const path = request.url;
  
  // Store the client based on the path
  if (!clientsByPath[path]) {
    clientsByPath[path] = [];
  }
  clientsByPath[path].push(client);
  if (savesByPath[path])
    savesByPath[path].forEach(c => {client.send(c)});

  // Listen for messages from the client
  client.on('message', (message) => {
    if (!savesByPath[path]){
        savesByPath[path] = [];
    }
    savesByPath[path].push(message)
    // Send the message to all clients on the same path
    const clients = clientsByPath[path];
    for (const c of clients) {
      c.send(message);
    }
  });

  // Clean up when a client disconnects
  client.on('close', () => {
    const index = clientsByPath[path].indexOf(client);
    if (index !== -1) {
      clientsByPath[path].splice(index, 1);
    }
  });
});

// Create an HTTP server to handle WebSocket upgrades
const httpServer = require('http').createServer();
httpServer.on('upgrade', (request, socket, head) => {
  server.handleUpgrade(request, socket, head, (client) => {
    server.emit('connection', client, request);
  });
});

// Start the HTTP server on a specific port
const PORT = 8080;
httpServer.listen(PORT, () => {
  console.log(`WebSocket server is listening on port ${PORT}`);
});
