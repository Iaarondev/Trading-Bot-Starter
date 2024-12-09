"""Grid Trading Strategy"""
import asyncio
from decimal import Decimal
from typing import Dict
from grid_trading.core.exchange import ExchangeInterface
from grid_trading.database.models import GridConfig

class GridStrategy:
    def __init__(
        self,
        exchange: ExchangeInterface,
        config: GridConfig,
        check_interval: float = 1.0
    ):
        self.exchange = exchange
        self.config = config
        self.check_interval = check_interval
        self.active_orders: Dict[str, str] = {}
        self.is_running = False

    async def start(self):
        self.is_running = True
        await self._initialize_grid()
        while self.is_running:
            await self._check_and_update_orders()
            await asyncio.sleep(self.check_interval)

    async def stop(self):
        self.is_running = False
