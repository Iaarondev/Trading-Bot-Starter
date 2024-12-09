"""
Trading Strategy Interface

This module defines the base interface for trading strategies.
It provides a framework for implementing different trading algorithms.

Features:
- Strategy lifecycle management
- Risk management integration
- Performance tracking
- Event handling
"""

from abc import ABC, abstractmethod
from decimal import Decimal
from typing import Dict, List, Optional

from grid_trading.core.exchange import ExchangeInterface
from grid_trading.database.models import GridConfig, Order

class TradingStrategy(ABC):
    """Base class for trading strategies."""
    
    @abstractmethod
    async def initialize(self) -> None:
        """Performs strategy initialization."""
        pass
    
    @abstractmethod
    async def start(self) -> None:
        """Starts the trading strategy."""
        pass
    
    @abstractmethod
    async def stop(self) -> None:
        """Stops the trading strategy."""
        pass
    
    @abstractmethod
    async def on_price_update(self, price: Decimal) -> None:
        """Handles price updates."""
        pass
    
    @abstractmethod
    async def on_order_filled(self, order: Order) -> None:
        """Handles order fill events."""
        pass
