"""
Exchange Interface Definition

This module defines the base interface that all exchange implementations must follow.
It provides a consistent API for interacting with different cryptocurrency exchanges.

Key Features:
- Abstract base class for exchange implementations
- Type hints for all methods
- Comprehensive documentation
- Error handling patterns
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from decimal import Decimal
from typing import Dict, List, Optional, Tuple

@dataclass
class OrderBook:
    """Represents the order book state at a point in time."""
    bids: List[Tuple[Decimal, Decimal]]  # (price, quantity) pairs
    asks: List[Tuple[Decimal, Decimal]]  # (price, quantity) pairs
    timestamp: float

@dataclass
class TradeInfo:
    """Contains information about a completed trade."""
    id: str
    price: Decimal
    quantity: Decimal
    side: str  # 'buy' or 'sell'
    timestamp: float
    fee: Decimal
    fee_currency: str

class ExchangeInterface(ABC):
    """Abstract base class defining the interface for exchange implementations."""
    
    @abstractmethod
    async def get_order_book(self, symbol: str) -> OrderBook:
        """
        Fetches the current order book for a trading pair.
        
        Args:
            symbol: Trading pair symbol (e.g., 'BTC-USD')
            
        Returns:
            OrderBook: Current order book state
            
        Raises:
            ExchangeError: If there's an error fetching the order book
        """
        pass
    
    @abstractmethod
    async def place_limit_order(
        self,
        symbol: str,
        side: str,
        price: Decimal,
        quantity: Decimal
    ) -> str:
        """
        Places a limit order on the exchange.
        
        Args:
            symbol: Trading pair symbol
            side: 'buy' or 'sell'
            price: Order price
            quantity: Order quantity
            
        Returns:
            str: Order ID
            
        Raises:
            InsufficientFundsError: If account balance is too low
            InvalidOrderError: If order parameters are invalid
            ExchangeError: For other exchange-related errors
        """
        pass
    
    @abstractmethod
    async def cancel_order(self, symbol: str, order_id: str) -> bool:
        """Cancels an existing order."""
        pass
    
    @abstractmethod
    async def get_account_balance(self, currency: str) -> Decimal:
        """Fetches the current balance for a currency."""
        pass
    
    @abstractmethod
    async def get_ticker(self, symbol: str) -> Dict[str, Decimal]:
        """Fetches current price ticker."""
        pass
