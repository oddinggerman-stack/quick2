const http = require('http');

const PORT = process.env.PORT || 8080;

const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Powerplay - Player Dashboard</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a2e; color: #eee; margin: 0; padding: 20px; }
    h1 { color: #e94560; }
    .card { background: #16213e; border-radius: 8px; padding: 20px; margin: 10px 0; }
    .metric { font-size: 2em; color: #0f3460; font-weight: bold; color: #e94560; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; }
  </style>
</head>
<body>
  <h1>Powerplay Player Dashboard</h1>
  <div class="grid">
    <div class="card">
      <h3>Active Players</h3>
      <div class="metric" id="players">142</div>
    </div>
    <div class="card">
      <h3>Game Servers Online</h3>
      <div class="metric">2</div>
    </div>
    <div class="card">
      <h3>Avg Latency</h3>
      <div class="metric">24ms</div>
    </div>
    <div class="card">
      <h3>Matches in Progress</h3>
      <div class="metric">12</div>
    </div>
  </div>
  <div class="card" style="margin-top:20px">
    <h3>Server Status</h3>
    <p>Game Server A (Zone 1): <span style="color:#4ecca3">ONLINE</span></p>
    <p>Game Server B (Zone 2): <span style="color:#4ecca3">ONLINE</span></p>
  </div>
</body>
</html>`;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy', service: 'player-dashboard' }));
    return;
  }
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(html);
});

server.listen(PORT, () => {
  console.log(`Player Dashboard running on port ${PORT}`);
});
