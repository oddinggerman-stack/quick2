const http = require('http');

const PORT = process.env.PORT || 8080;

const gameServers = [
  { id: 'gs-a', name: 'Game Server A', zone: 1, players: 64, maxPlayers: 100, ip: '10.1.2.4' },
  { id: 'gs-b', name: 'Game Server B', zone: 2, players: 38, maxPlayers: 100, ip: '10.1.2.5' },
];

function handleRequest(req, res) {
  res.setHeader('Content-Type', 'application/json');

  if (req.url === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify({ status: 'healthy', service: 'matchmaking-api' }));
    return;
  }

  if (req.url === '/api/servers' && req.method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify({ servers: gameServers }));
    return;
  }

  if (req.url === '/api/match' && req.method === 'POST') {
    // Pick the server with the fewest players
    const best = gameServers.reduce((a, b) => a.players < b.players ? a : b);
    res.writeHead(200);
    res.end(JSON.stringify({
      matched: true,
      server: best.name,
      ip: best.ip,
      zone: best.zone,
    }));
    return;
  }

  res.writeHead(404);
  res.end(JSON.stringify({ error: 'Not found', endpoints: ['/api/servers', '/api/match', '/health'] }));
}

const server = http.createServer(handleRequest);

server.listen(PORT, () => {
  console.log(`Matchmaking API running on port ${PORT}`);
});
