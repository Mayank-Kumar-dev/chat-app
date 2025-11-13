# Base image from AWS ECR Public (no rate limits)
FROM public.ecr.aws/docker/library/node:18

# Set work directory
WORKDIR /app

# Copy dependency files first (better build caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy remaining source code
COPY . .

# Expose app port
EXPOSE 3000

# Start command
CMD ["node", "app.js"]
