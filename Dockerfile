# 1. Grab a standard, pre-packaged lightweight Linux box with Node.js pre-installed
FROM node:18-alpine

# 2. Step inside the container and create a working directory room
WORKDIR /usr/src/app

# 3. Inject a mini web server directly into the container using an inline script
CMD ["node", "-e", "const http = require('http'); http.createServer((req, res) => res.end('Container Live!')).listen(8080); console.log('Server running on port 8080');"]

# 4. Open up port 8080 on the container wall so traffic can enter
EXPOSE 8080
