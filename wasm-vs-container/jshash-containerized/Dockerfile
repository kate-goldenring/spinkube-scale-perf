
# Use the official Node.js 14 image as the base image
FROM node:17-slim

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Expose port 3000
EXPOSE 3000

# Command to run the application
CMD ["node", "src/index.js"]
