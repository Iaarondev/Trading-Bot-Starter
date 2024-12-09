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
