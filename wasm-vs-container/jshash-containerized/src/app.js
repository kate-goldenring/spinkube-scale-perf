const express = require('express')
const crypto = require('crypto')
const app = express()
const port = 3000

app.post('/', (req, res) => {
  if (req.method !== 'POST') {
    res.writeHead(405, { 'Content-Type': 'text/plain' });
    res.end('Method Not Allowed');
    return;
}

let body = '';
req.on('data', chunk => {
    body += chunk;
});

req.on('end', () => {
    try {
        const data = JSON.parse(body);
        const hash = calculateHash(data.message);

        const responseData = {
            message: data.message,
            hash: hash
        };

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(responseData));
    } catch (error) {
        console.error('Error:', error.message);
        res.writeHead(400, { 'Content-Type': 'text/plain' });
        res.end('Bad Request');
    }
});
})

const server = app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server')
  server.close(() => {
    console.log('HTTP server closed')
  })
})

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server')
  server.close(() => {
    console.log('HTTP server closed')
  })
})

function calculateHash(message) {
  const hash = crypto.createHash('sha256', message).digest('hex');
  return hash;
  }
