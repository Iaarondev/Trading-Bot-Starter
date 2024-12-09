#!/bin/bash
source ./common.sh

PROJECT_DIR=${1:-grid_trading_bot}

# Create Docker setup
./create_docker.sh "$PROJECT_DIR"
./create_ci.sh "$PROJECT_DIR"
./create_safety.sh "$PROJECT_DIR"

echo "Advanced components added successfully"
