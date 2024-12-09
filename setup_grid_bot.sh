#!/bin/bash

# ============================================================================
# Grid Trading Bot Project Setup Script
# Author: Your Name
# Date: 2024-12-08
# 
# This script creates the directory structure and necessary files for the
# Grid Trading Bot project. It includes developer comments and placeholder files.
# 
# Usage:
#   ./setup_grid_bot.sh [project_name] [--force] [--minimal]
#   If no project name is provided, defaults to 'grid_trading_bot'
#   --force: Override existing directory
#   --minimal: Create minimal project structure
# ============================================================================

set -euo pipefail  # Exit on error, undefined var, pipe failure

# Set project name and parse arguments
PROJECT_NAME="grid_trading_bot"
FORCE_CREATE=false
MINIMAL_SETUP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_CREATE=true
            shift
            ;;
        --minimal)
            MINIMAL_SETUP=true
            shift
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

# Error handling
handle_error() {
    log_error "An error occurred on line $1"
    exit 1
}

trap 'handle_error ${LINENO}' ERR

# Verify system requirements
check_requirements() {
    log_info "Checking system requirements..."
    
    # Check for required commands
    local required_commands=("python3" "git" "pip")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "$cmd is required but not installed."
            exit 1
        fi
    done
    
    # Check Python version using version comparison
    local python_version=$(python3 -c 'import sys; print(f"{sys.version_info[0]}{sys.version_info[1]:02d}")')
    if (( python_version < 308 )); then
        log_error "Python 3.8 or higher is required (found $(python3 -V))"
        exit 1
    fi
}

# Create main project directory
create_project_structure() {
    log_info "Creating project structure for $PROJECT_NAME..."
    
    # Directory structure with descriptions
    declare -A project_dirs=(
        ["grid_trading/config"]="Configuration management"
        ["grid_trading/core"]="Core business logic"
        ["grid_trading/database"]="Database models and operations"
        ["grid_trading/exchanges"]="Exchange implementations"
        ["grid_trading/utils"]="Utility functions"
        ["grid_trading/strategies"]="Trading strategies"
        ["grid_trading/monitoring"]="Monitoring and alerting"
        ["tests/unit"]="Unit tests"
        ["tests/integration"]="Integration tests"
        ["docs/api"]="API documentation"
        ["docs/guides"]="User guides"
        ["scripts"]="Development scripts"
        ["examples"]="Example implementations"
    )
    
    # Create directories
    for dir in "${!project_dirs[@]}"; do
        if [ "$MINIMAL_SETUP" = true ] && [[ "$dir" =~ ^(examples|docs/api|docs/guides)$ ]]; then
            continue
        fi
        mkdir -p "$PROJECT_NAME/$dir"
        echo "# ${project_dirs[$dir]}" > "$PROJECT_NAME/$dir/README.md"
    done
    
    # Create __init__.py files
    find "$PROJECT_NAME/grid_trading" -type d -exec touch {}/__init__.py \;
    
    # Create .gitignore
    cat > "$PROJECT_NAME/.gitignore" << EOL
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
env/
ENV/

# IDEs
.idea/
.vscode/
*.swp
*.swo

# Local Development
.env
*.log
.coverage
htmlcov/
.pytest_cache/
.mypy_cache/

# Project Specific
*.db
logs/
data/
EOL

    log_info "Basic directory structure created."
}

# Create virtual environment
create_virtual_environment() {
    log_info "Creating virtual environment..."
    
    cd "$PROJECT_NAME"
    python3 -m venv venv
    
    # Create activation script for different shells
    cat > "scripts/activate_venv.sh" << EOL
#!/bin/bash
# Source this file to activate the virtual environment
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
else
    echo "Virtual environment not found. Run setup script first."
    exit 1
fi
EOL
    
    cat > "scripts/activate_venv.ps1" << EOL
# PowerShell activation script
if (Test-Path "venv/Scripts/Activate.ps1") {
    & "./venv/Scripts/Activate.ps1"
} else {
    Write-Error "Virtual environment not found. Run setup script first."
    exit 1
}
EOL
    
    chmod +x scripts/activate_venv.sh
    cd ..
}

# Add GitHub Actions workflow
create_github_workflow() {
    if [ "$MINIMAL_SETUP" = true ]; then
        return
    fi
    
    log_info "Creating GitHub Actions workflow..."
    
    mkdir -p "$PROJECT_NAME/.github/workflows"
    cat > "$PROJECT_NAME/.github/workflows/ci.yml" << EOL
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, "3.10", "3.11"]

    steps:
    - uses: actions/checkout@v3
    - name: Set up Python \${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: \${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    - name: Run tests
      run: |
        pytest tests/ --cov=grid_trading --cov-report=xml
    - name: Upload coverage
      uses: codecov/codecov-action@v3
EOL
}

# Create Makefile for common commands
create_makefile() {
    log_info "Creating Makefile..."
    
    cat > "$PROJECT_NAME/Makefile" << EOL
.PHONY: setup test lint clean docs

setup:
	python3 -m venv venv
	. venv/bin/activate && pip install -r requirements.txt

test:
	pytest tests/ --cov=grid_trading --cov-report=html -v

lint:
	black grid_trading tests
	isort grid_trading tests
	flake8 grid_trading tests
	mypy grid_trading

clean:
	find . -type d -name __pycache__ -exec rm -r {} +
	find . -type d -name .pytest_cache -exec rm -r {} +
	find . -type d -name .coverage -exec rm -r {} +
	find . -type d -name htmlcov -exec rm -r {} +

docs:
	pdoc --html --output-dir docs/api grid_trading

install-dev:
	pip install -e ".[dev]"
EOL
}

# Main execution
main() {
    log_info "Starting setup for Grid Trading Bot project..."
    
    # Check if directory exists
    if [ -d "$PROJECT_NAME" ]; then
        if [ "$FORCE_CREATE" = true ]; then
            log_warning "Removing existing directory $PROJECT_NAME"
            rm -rf "$PROJECT_NAME"
        else
            log_error "Directory $PROJECT_NAME already exists! Use --force to override."
            exit 1
        fi
    fi
    
    # Run setup steps
    check_requirements
    create_project_structure
    create_config_files
    create_documentation
    create_requirements
    create_test_files
    create_scripts
    create_virtual_environment
    create_github_workflow
    create_makefile
    
    log_info "Project setup complete! Next steps:"
    echo "1. cd $PROJECT_NAME"
    echo "2. make setup"
    echo "3. source scripts/activate_venv.sh  # On Windows: . ./scripts/activate_venv.ps1"
    echo "4. make test  # Run tests"
    echo "5. make lint  # Run linting"
}

main