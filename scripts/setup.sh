#!/bin/bash
source ./common.sh

PROJECT_NAME=${1:-grid_trading_bot}
FORCE_CREATE=false
MINIMAL_SETUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force) FORCE_CREATE=true; shift ;;
        --minimal) MINIMAL_SETUP=true; shift ;;
        *) PROJECT_NAME="$1"; shift ;;
    esac
done

main() {
    log_info "Starting project setup: $PROJECT_NAME"
    
    check_dependencies
    validate_python_version
    
    if [[ -d "$PROJECT_NAME" && "$FORCE_CREATE" == false ]]; then
        log_error "Directory exists. Use --force to override."
        exit 1
    fi
    
    ensure_directory "$PROJECT_NAME"
    
    for script in create_*.sh; do
        if [[ -x "$script" ]]; then
            log_info "Running $script"
            ./"$script" "$PROJECT_NAME"
        fi
    done
    
    log_info "Setup complete!"
}

main
