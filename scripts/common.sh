#!/bin/bash
set -euo pipefail

export GREEN='\033[0;32m'
export RED='\033[0;31m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'
export NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

check_dependencies() {
    local deps=("python3" "pip" "git" "docker")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "$dep is required but not installed"
            exit 1
        fi
    done
}

validate_python_version() {
    local version=$(python3 -c 'import sys; print(f"{sys.version_info[0]}{sys.version_info[1]:02d}")')
    if (( version < 308 )); then
        log_error "Python 3.8+ required (found $(python3 -V))"
        exit 1
    fi
}

handle_error() {
    log_error "Error on line $1"
    exit 1
}

trap 'handle_error ${LINENO}' ERR
