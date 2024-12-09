#!/bin/bash
source ./common.sh

create_ci() {
    local project_dir=$1
    
    mkdir -p "$project_dir/.github/workflows"
    
    # Create GitHub Actions workflow
    cat > "$project_dir/.github/workflows/main.yml" << 'GHACTIONS'
name: CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    - name: Run tests
      run: |
        pytest --cov=grid_trading tests/
        coverage xml
GHACTIONS
}

create_ci "${1:-grid_trading_bot}"
