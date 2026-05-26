const http = require('http');
const { Client } = require('pg');

// 1. Configure connection to read Environment Variables injected by Terraform!
const client = new Client({
  user: process.env.DB_USER || 'admin',
  password: process.env.DB_PASSWORD || 'secretpassword',
  database: process.env.DB_NAME || 'enterprise_data',
  host: process.env.DB_HOST || 'database', // This will now catch the AWS RDS URL!
  port: 5432,
});

// 2. Connect to the database
client.connect()
  .then(() => console.log('✅ Connected to PostgreSQL!'))
  .catch(err => {
    console.error('❌ Database connection error', err.stack);
    process.exit(1); // Force crash so Docker restarts it!
  });

// 3. Start the Web Server
const server = http.createServer(async (req, res) => {
  try {
    const dbRes = await client.query('SELECT NOW()');
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`Production Live! AWS RDS time is: ${dbRes.rows[0].now}\n`);
  } catch (err) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('Database disconnected.\n');
  }
});

server.listen(8080, () => {
  console.log('Server running on port 8080');
});
