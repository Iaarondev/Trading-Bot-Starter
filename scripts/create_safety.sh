#!/bin/bash
source ./common.sh

create_safety() {
    local project_dir=$1
    
    mkdir -p "$project_dir/grid_trading/core"
    
    # Create risk management
    cat > "$project_dir/grid_trading/core/risk.py" << 'PYFILE'
from dataclasses import dataclass
from decimal import Decimal

@dataclass
class RiskLimits:
    max_position_size: Decimal
    max_order_size: Decimal
    max_drawdown: Decimal
    max_daily_loss: Decimal

class RiskManager:
    def __init__(self, limits: RiskLimits):
        self.limits = limits
    
    async def check_order(self, size: Decimal) -> bool:
        return size <= self.limits.max_order_size
PYFILE
}

create_safety "${1:-grid_trading_bot}"
