const WebSocket = require('ws');

// Create a WebSocket server
const wss = new WebSocket.Server({ port: 8080 });

// Store connected clients
var clients = [];

var storedGameData = {}

function getPath(ws, request)
{
    const url = new URL(request.url, `http://${request.headers.host}`);
    return url.pathname
}

// When a client connects
wss.on('connection', (ws, request) => {
  const path = getPath(ws, request)
  if (!(path in storedGameData))
    storedGameData[path] = []
  storedGameData[path].forEach(e=>{
    ws.send(e)
  })
  console.log(path)
  clients.push({"client":ws,"path":path})

  // When the client sends a message
  ws.on('message', (message) => {
    for(client in clients)
    {
        console.log(client)
        if (client["path"] == path)
        {
            client["client"].send(message)
        }
    }
  });

  // When the client closes the connection
  ws.on('close', () => {
    clients.delete(ws);
  });
});

console.log('WebSocket server is running on port 8080');
