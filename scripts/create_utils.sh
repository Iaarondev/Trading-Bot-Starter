#!/bin/bash
source ./common.sh

create_utils() {
    local project_dir=$1
    ensure_directory "$project_dir/grid_trading/utils"

    # Create rate limiter
    cat > "$project_dir/grid_trading/utils/rate_limiter.py" << 'PYFILE'
"""Rate Limiter Implementation"""
import asyncio
import time

class RateLimiter:
    def __init__(self, max_requests: int, time_window: float):
        self.max_requests = max_requests
        self.time_window = time_window
        self.tokens = max_requests
        self.last_update = time.monotonic()
        self.lock = asyncio.Lock()

    async def acquire(self):
        async with self.lock:
            now = time.monotonic()
            time_passed = now - self.last_update
            self.tokens = min(
                self.max_requests,
                self.tokens + (time_passed * self.max_requests / self.time_window)
            )
            self.last_update = now

            if self.tokens < 1:
                await asyncio.sleep(0.1)
            else:
                self.tokens -= 1
PYFILE

    # Create config validator
    cat > "$project_dir/grid_trading/utils/validation.py" << 'PYFILE'
"""Configuration Validation"""
from decimal import Decimal
from typing import Dict, Any
from pydantic import BaseModel, validator

class GridConfig(BaseModel):
    symbol: str
    grid_size: int
    upper_price: Decimal
    lower_price: Decimal
    quantity_per_order: Decimal

    @validator('grid_size')
    def validate_grid_size(cls, v):
        if v < 2:
            raise ValueError("Grid size must be at least 2")
        return v
PYFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_utils "${1:-grid_trading_bot}"
fi
