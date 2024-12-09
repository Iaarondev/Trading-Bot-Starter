"""
Grid Trading Strategy Implementation

This module implements a grid trading strategy that places buy and sell
orders at regular price intervals within a specified range.

Features:
- Dynamic grid sizing
- Auto-rebalancing
- Position tracking
- Risk management
"""

import asyncio
from decimal import Decimal
from typing import List, Dict, Optional

from grid_trading.core.strategy import TradingStrategy
from grid_trading.core.exchange import ExchangeInterface
from grid_trading.database.models import GridConfig, Order
from grid_trading.utils.logger import get_logger

logger = get_logger(__name__)

class GridTradingStrategy(TradingStrategy):
    """Implementation of grid trading strategy."""
    
    def __init__(
        self,
        exchange: ExchangeInterface,
        config: GridConfig,
        price_update_interval: float = 1.0
    ):
        """Initialize grid trading strategy."""
        self.exchange = exchange
        self.config = config
        self.price_update_interval = price_update_interval
        self.active_orders: Dict[str, Order] = {}
        self.is_running = False
        
    async def initialize(self) -> None:
        """Sets up the initial grid of orders."""
        logger.info(f"Initializing grid for {self.config.symbol}")
        
        # Calculate grid levels
        price_step = (self.config.upper_price - self.config.lower_price) / (self.config.grid_size - 1)
        
        # Place initial orders
        for i in range(self.config.grid_size):
            price = self.config.lower_price + (price_step * i)
            # Place buy orders below current price, sell orders above
            current_price = await self._get_current_price()
            if price < current_price:
                await self._place_grid_order("buy", price)
            else:
                await self._place_grid_order("sell", price)
    
    async def _place_grid_order(self, side: str, price: Decimal) -> None:
        """Places a single grid order."""
        try:
            order_id = await self.exchange.place_limit_order(
                self.config.symbol,
                side,
                price,
                self.config.quantity_per_order
            )
            logger.info(f"Placed {side} order at {price}: {order_id}")
        except Exception as e:
            logger.error(f"Error placing {side} order at {price}: {e}")
