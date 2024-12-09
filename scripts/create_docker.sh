#!/bin/bash
source ./common.sh

create_docker() {
    local project_dir=$1
    
    # Create Dockerfile
    cat > "$project_dir/Dockerfile" << 'DOCKERFILE'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "grid_trading"]
DOCKERFILE

    # Create docker-compose.yml
    cat > "$project_dir/docker-compose.yml" << 'DOCKERCOMPOSE'
version: '3.8'

services:
  bot:
    build: .
    env_file: .env
    volumes:
      - ./data:/app/data
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: grid_trading

volumes:
  pgdata:
DOCKERCOMPOSE
}

create_docker "${1:-grid_trading_bot}"
