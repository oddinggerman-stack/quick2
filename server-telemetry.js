const net = require('net');
const http = require('http');

const TCP_PORT = process.env.TCP_PORT || 5170;
const HTTP_PORT = process.env.HTTP_PORT || 8080;

const logBuffer = [];
const MAX_BUFFER = 1000;

// TCP server - receives logs from game servers
const tcpServer = net.createServer((socket) => {
  console.log(`Connection from ${socket.remoteAddress}:${socket.remotePort}`);

  socket.on('data', (data) => {
    const message = data.toString().trim();
    const entry = {
      timestamp: new Date().toISOString(),
      source: socket.remoteAddress,
      message,
    };
    logBuffer.push(entry);
    if (logBuffer.length > MAX_BUFFER) logBuffer.shift();
    console.log(`[LOG] ${entry.timestamp} | ${entry.source} | ${message}`);
  });

  socket.on('error', (err) => {
    console.error(`Socket error: ${err.message}`);
  });
});

// HTTP server - health check and log viewer
const httpServer = http.createServer((req, res) => {
  res.setHeader('Content-Type', 'application/json');

  if (req.url === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify({ status: 'healthy', service: 'telemetry-collector', logsReceived: logBuffer.length }));
    return;
  }

  if (req.url === '/logs') {
    res.writeHead(200);
    res.end(JSON.stringify({ count: logBuffer.length, logs: logBuffer.slice(-50) }));
    return;
  }

  res.writeHead(200);
  res.end(JSON.stringify({ service: 'telemetry-collector', endpoints: ['/health', '/logs'] }));
});

tcpServer.listen(TCP_PORT, () => {
  console.log(`Telemetry Collector TCP listening on port ${TCP_PORT}`);
});

httpServer.listen(HTTP_PORT, () => {
  console.log(`Telemetry Collector HTTP listening on port ${HTTP_PORT}`);
});
