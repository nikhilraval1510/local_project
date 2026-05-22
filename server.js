const http = require('http');
const { Client } = require('pg');

// 1. Configure the connection to match our docker-compose.yml
const client = new Client({
  user: 'admin',
  host: 'database', // Docker automatically routes this to the Postgres container!
  database: 'enterprise_data',
  password: 'secretpassword',
  port: 5432,
});

// 2. Connect to the database
client.connect()
  .then(() => console.log('✅ Connected to PostgreSQL!'))
  .catch(err => console.error('❌ Database connection error', err.stack));

// 3. Start the Web Server
const server = http.createServer(async (req, res) => {
  try {
    // Ask the database what time it is to prove the connection works
    const dbRes = await client.query('SELECT NOW()');
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`Container Live! Database time is: ${dbRes.rows[0].now}\n`);
  } catch (err) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('Database disconnected.\n');
  }
});

server.listen(8080, () => {
  console.log('Server running on port 8080');
});
