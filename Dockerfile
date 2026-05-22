# 1. Base Image
FROM node:18-alpine

# 2. Working Directory
WORKDIR /usr/src/app

# 3. Copy dependencies and install them
COPY package.json ./
RUN npm install

# 4. Copy the actual application code
COPY server.js ./

# 5. DEVSECOPS FIX: Drop privileges
USER node

# 6. Run the real server file instead of the inline script
CMD ["node", "server.js"]

# 7. Expose the port
EXPOSE 8080
