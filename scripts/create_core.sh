#!/bin/bash
source ./common.sh

create_core() {
    local project_dir=$1
    ensure_directory "$project_dir/grid_trading/core"

    # Create exchange interface
    cat > "$project_dir/grid_trading/core/exchange.py" << 'PYFILE'
"""Exchange Interface Definition"""
from abc import ABC, abstractmethod
from dataclasses import dataclass
from decimal import Decimal
from typing import Dict, List, Tuple

@dataclass
class OrderBook:
    bids: List[Tuple[Decimal, Decimal]]
    asks: List[Tuple[Decimal, Decimal]]
    timestamp: float

class ExchangeInterface(ABC):
    @abstractmethod
    async def get_order_book(self, symbol: str) -> OrderBook:
        """Fetch current orderbook"""
        pass

    @abstractmethod
    async def place_limit_order(
        self, symbol: str, side: str,
        price: Decimal, quantity: Decimal
    ) -> str:
        """Place a limit order"""
        pass
PYFILE

    # Create exceptions
    cat > "$project_dir/grid_trading/core/exceptions.py" << 'PYFILE'
class ExchangeError(Exception):
    """Base exception for exchange errors"""
    pass

class InsufficientFundsError(ExchangeError):
    """Raised when account has insufficient funds"""
    pass

class InvalidOrderError(ExchangeError):
    """Raised when order parameters are invalid"""
    pass
PYFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_core "${1:-grid_trading_bot}"
fi
