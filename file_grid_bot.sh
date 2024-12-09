#!/bin/bash

# ============================================================================
# Grid Trading Bot Template Files Creation Script
# Author: Your Name
# Date: 2024-12-08
# 
# This script creates template files with documentation and sample implementations
# for the Grid Trading Bot project. It should be run after the initial setup script.
# 
# Usage:
#   ./create_templates.sh [project_dir]
#   If no project directory is provided, defaults to 'grid_trading_bot'
# ============================================================================

set -euo pipefail

PROJECT_DIR=${1:-grid_trading_bot}

# Color codes for output
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

# Create exchange interface and implementation
create_exchange_files() {
    log_info "Creating exchange interface and implementation..."
    
    # Create exchange interface
    cat > "$PROJECT_DIR/grid_trading/core/exchange.py" << 'EOL'
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
EOL

    # Create Coinbase exchange implementation
    cat > "$PROJECT_DIR/grid_trading/exchanges/coinbase.py" << 'EOL'
"""
Coinbase Exchange Implementation

This module implements the ExchangeInterface for the Coinbase exchange.
It handles API communication, rate limiting, and error handling specific
to Coinbase's API.

Features:
- Automatic rate limiting
- Retry mechanism for transient errors
- Comprehensive error handling
- Logging of API interactions
"""

import asyncio
import hmac
import hashlib
import time
from decimal import Decimal
from typing import Dict, Optional

from grid_trading.core.exchange import ExchangeInterface, OrderBook, TradeInfo
from grid_trading.utils.rate_limiter import RateLimiter

class CoinbaseExchange(ExchangeInterface):
    """Coinbase exchange implementation."""
    
    def __init__(
        self,
        api_key: str,
        api_secret: str,
        base_url: str = "https://api.coinbase.com",
    ):
        """Initialize Coinbase exchange connection."""
        self.api_key = api_key
        self.api_secret = api_secret
        self.base_url = base_url
        self.rate_limiter = RateLimiter(
            max_requests=30,
            time_window=1.0
        )
    
    async def _sign_request(self, method: str, path: str, body: str = "") -> Dict[str, str]:
        """Creates authentication signature for API requests."""
        timestamp = str(int(time.time()))
        message = timestamp + method + path + body
        signature = hmac.new(
            self.api_secret.encode(),
            message.encode(),
            hashlib.sha256
        ).hexdigest()
        
        return {
            "CB-ACCESS-KEY": self.api_key,
            "CB-ACCESS-SIGN": signature,
            "CB-ACCESS-TIMESTAMP": timestamp,
        }
    
    async def get_order_book(self, symbol: str) -> OrderBook:
        """Implementation of order book fetching for Coinbase."""
        async with self.rate_limiter:
            # Implementation details here
            pass
    
    async def place_limit_order(
        self,
        symbol: str,
        side: str,
        price: Decimal,
        quantity: Decimal
    ) -> str:
        """Implementation of limit order placement for Coinbase."""
        async with self.rate_limiter:
            # Implementation details here
            pass
EOL
}

# Create database models and utilities
create_database_files() {
    log_info "Creating database models and utilities..."
    
    # Create database models
    cat > "$PROJECT_DIR/grid_trading/database/models.py" << 'EOL'
"""
Database Models

This module defines the SQLAlchemy models for persisting trading data.
It includes models for orders, trades, grid configurations, and performance metrics.

Key Features:
- SQLAlchemy ORM models
- Type annotations
- Migration support
- Relationship definitions
"""

from datetime import datetime
from decimal import Decimal
from typing import List, Optional

from sqlalchemy import (
    Column, Integer, String, Float, Numeric,
    ForeignKey, DateTime, Enum, Boolean
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class GridConfig(Base):
    """Stores grid trading configuration."""
    __tablename__ = 'grid_configs'
    
    id = Column(Integer, primary_key=True)
    symbol = Column(String, nullable=False)
    grid_size = Column(Integer, nullable=False)
    upper_price = Column(Numeric(precision=18, scale=8), nullable=False)
    lower_price = Column(Numeric(precision=18, scale=8), nullable=False)
    quantity_per_order = Column(Numeric(precision=18, scale=8), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)
    
    # Relationships
    orders = relationship("Order", back_populates="grid_config")

class Order(Base):
    """Stores order information."""
    __tablename__ = 'orders'
    
    id = Column(Integer, primary_key=True)
    exchange_order_id = Column(String, nullable=False)
    grid_config_id = Column(Integer, ForeignKey('grid_configs.id'))
    side = Column(Enum('buy', 'sell', name='order_side'), nullable=False)
    price = Column(Numeric(precision=18, scale=8), nullable=False)
    quantity = Column(Numeric(precision=18, scale=8), nullable=False)
    status = Column(
        Enum('pending', 'filled', 'cancelled', name='order_status'),
        nullable=False
    )
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)
    
    # Relationships
    grid_config = relationship("GridConfig", back_populates="orders")
    trades = relationship("Trade", back_populates="order")
EOL

    # Create database connection utility
    cat > "$PROJECT_DIR/grid_trading/database/connection.py" << 'EOL'
"""
Database Connection Management

This module handles database connection pooling and session management.
It provides a context manager for safe database operations.

Features:
- Connection pooling
- Session management
- Migration support
- Error handling
"""

import contextlib
from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool

class DatabaseConnection:
    """Manages database connections and sessions."""
    
    def __init__(
        self,
        connection_url: str,
        pool_size: int = 5,
        max_overflow: int = 10
    ):
        """Initialize database connection manager."""
        self.engine = create_engine(
            connection_url,
            poolclass=QueuePool,
            pool_size=pool_size,
            max_overflow=max_overflow,
            pool_pre_ping=True
        )
        self.SessionLocal = sessionmaker(
            autocommit=False,
            autoflush=False,
            bind=self.engine
        )
    
    @contextlib.contextmanager
    def get_session(self) -> Generator[Session, None, None]:
        """Provides a transactional scope around a series of operations."""
        session = self.SessionLocal()
        try:
            yield session
            session.commit()
        except Exception:
            session.rollback()
            raise
        finally:
            session.close()
EOL
}

# Create strategy implementations
create_strategy_files() {
    log_info "Creating trading strategy implementations..."
    
    # Create base strategy interface
    cat > "$PROJECT_DIR/grid_trading/core/strategy.py" << 'EOL'
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
EOL

    # Create grid trading strategy implementation
    cat > "$PROJECT_DIR/grid_trading/strategies/grid.py" << 'EOL'
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
EOL
}

# Create utility modules
create_utility_files() {
    log_info "Creating utility modules..."
    
    # Create rate limiter
    cat > "$PROJECT_DIR/grid_trading/utils/rate_limiter.py" << 'EOL'
"""
Rate Limiter Implementation

This module provides rate limiting functionality for API calls.
It helps prevent exceeding exchange API rate limits.

Features:
- Async support
- Token bucket algorithm
- Configurable limits
- Request queuing
"""

import asyncio
import time
from typing import Optional

class RateLimiter:
    """Implements token bucket rate limiting algorithm."""
    
    def __init__(
        self,
        max_requests: int,
        time_window: float,
        initial_tokens: Optional[int] = None
    ):
        """
        Initialize rate limiter.
        
        Args:
            max_requests: Maximum requests per time window
            time_window: Time window in seconds
            initial_tokens: Initial token count (defaults to max_requests)
        """
        self.max_requests = max_requests
        self.time_window = time_window
        self.tokens = initial_tokens or max_requests
        self.last_update = time.monotonic()
        self.lock = asyncio.Lock()
    
    async def acquire(self) -> None:
        """Acquires a token, waiting if necessary."""
        async with self.lock:
            while self.tokens <= 0:
                now = time.monotonic()
                time_passed = now - self.last_update
                self.tokens = min(
                    self.max_requests,
                    self.tokens + (time_passed * self.max
                    # Continue rate limiter implementation
    cat >> "$PROJECT_DIR/grid_trading/utils/rate_limiter.py" << 'EOL'
                    requests / self.time_window)
                )
                self.last_update = now
                
                if self.tokens <= 0:
                    await asyncio.sleep(0.1)
            
            self.tokens -= 1
    
    async def __aenter__(self):
        """Async context manager entry."""
        await self.acquire()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        pass
EOL

    # Create logger utility
    cat > "$PROJECT_DIR/grid_trading/utils/logger.py" << 'EOL'
"""
Logging Configuration

This module provides a consistent logging setup across the application.
It includes formatting, log rotation, and different log levels for different environments.

Features:
- Structured logging
- Log rotation
- Different handlers for different environments
- Custom formatting
"""

import logging
import sys
from datetime import datetime
from logging.handlers import RotatingFileHandler
from pathlib import Path
from typing import Optional

def get_logger(
    name: str,
    log_level: str = "INFO",
    log_file: Optional[str] = None,
    max_bytes: int = 10_485_760,  # 10MB
    backup_count: int = 5
) -> logging.Logger:
    """
    Creates a logger with consistent configuration.
    
    Args:
        name: Logger name (typically __name__)
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        log_file: Optional file path for logging
        max_bytes: Maximum size of log file before rotation
        backup_count: Number of backup files to keep
    
    Returns:
        logging.Logger: Configured logger instance
    """
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, log_level.upper()))
    
    # Create formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # File handler (if log_file specified)
    if log_file:
        file_handler = RotatingFileHandler(
            log_file,
            maxBytes=max_bytes,
            backupCount=backup_count
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    
    return logger
EOL

    # Create configuration loader
    cat > "$PROJECT_DIR/grid_trading/config/loader.py" << 'EOL'
"""
Configuration Loader

This module handles loading and validating configuration from various sources
(files, environment variables, command line arguments).

Features:
- YAML configuration support
- Environment variable override
- Schema validation
- Nested configuration
"""

import os
from pathlib import Path
from typing import Any, Dict, Optional

import yaml
from pydantic import BaseModel, validator

class ExchangeConfig(BaseModel):
    """Exchange-specific configuration."""
    api_key: str
    api_secret: str
    base_url: str
    rate_limit: int = 30

class GridConfig(BaseModel):
    """Grid trading strategy configuration."""
    trading_pair: str
    grid_size: int
    grid_spread: float
    base_order_size: float
    check_interval: int = 60
    
    @validator('grid_size')
    def validate_grid_size(cls, v):
        if v < 2:
            raise ValueError("grid_size must be at least 2")
        return v
    
    @validator('grid_spread')
    def validate_grid_spread(cls, v):
        if not 0 < v < 1:
            raise ValueError("grid_spread must be between 0 and 1")
        return v

class DatabaseConfig(BaseModel):
    """Database configuration."""
    path: str
    pool_size: int = 5

class Config(BaseModel):
    """Root configuration model."""
    exchange: ExchangeConfig
    grid: GridConfig
    database: DatabaseConfig

def load_config(config_path: Optional[str] = None) -> Config:
    """
    Loads configuration from file and environment variables.
    
    Args:
        config_path: Path to YAML config file
        
    Returns:
        Config: Validated configuration object
        
    Raises:
        ValueError: If configuration is invalid
    """
    # Default config path
    if not config_path:
        config_path = os.getenv('CONFIG_PATH', 'config.yaml')
    
    # Load from file
    with open(config_path) as f:
        config_dict = yaml.safe_load(f)
    
    # Override with environment variables
    if api_key := os.getenv('EXCHANGE_API_KEY'):
        config_dict['exchange']['api_key'] = api_key
    if api_secret := os.getenv('EXCHANGE_API_SECRET'):
        config_dict['exchange']['api_secret'] = api_secret
    
    # Validate and return
    return Config(**config_dict)
EOL

    # Create monitoring utilities
    cat > "$PROJECT_DIR/grid_trading/monitoring/metrics.py" << 'EOL'
"""
Performance Metrics Collection

This module handles collecting and storing performance metrics
for the trading bot.

Features:
- Performance tracking
- Profit/loss calculation
- Risk metrics
- Statistical analysis
"""

from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from typing import Dict, List, Optional

@dataclass
class TradingMetrics:
    """Represents trading performance metrics."""
    total_trades: int
    profitable_trades: int
    total_profit_loss: Decimal
    win_rate: float
    average_profit_per_trade: Decimal
    max_drawdown: Decimal
    sharpe_ratio: float
    timestamp: datetime

class MetricsCollector:
    """Collects and calculates trading metrics."""
    
    def __init__(self):
        """Initialize metrics collector."""
        self.trades: List[Dict] = []
        self.current_balance: Decimal = Decimal('0')
        self.peak_balance: Decimal = Decimal('0')
    
    def add_trade(
        self,
        price: Decimal,
        quantity: Decimal,
        side: str,
        timestamp: datetime,
        fees: Decimal
    ) -> None:
        """Records a new trade."""
        trade = {
            'price': price,
            'quantity': quantity,
            'side': side,
            'timestamp': timestamp,
            'fees': fees
        }
        self.trades.append(trade)
        
        # Update balance
        trade_value = price * quantity
        if side == 'buy':
            self.current_balance -= trade_value + fees
        else:
            self.current_balance += trade_value - fees
            
        # Update peak balance
        if self.current_balance > self.peak_balance:
            self.peak_balance = self.current_balance
    
    def calculate_metrics(self) -> TradingMetrics:
        """Calculates current performance metrics."""
        # Implementation of various trading metrics calculations
        pass
EOL

    # Create CLI interface
    cat > "$PROJECT_DIR/grid_trading/cli.py" << 'EOL'
"""
Command Line Interface

This module provides a command-line interface for controlling
the trading bot.

Features:
- Start/stop trading
- Configuration management
- Status monitoring
- Performance reporting
"""

import argparse
import asyncio
from pathlib import Path
from typing import Optional

import click
from rich.console import Console
from rich.table import Table

from grid_trading.config.loader import load_config
from grid_trading.core.exchange import ExchangeInterface
from grid_trading.exchanges.coinbase import CoinbaseExchange
from grid_trading.strategies.grid import GridTradingStrategy
from grid_trading.monitoring.metrics import MetricsCollector

console = Console()

@click.group()
def cli():
    """Grid Trading Bot CLI"""
    pass

@cli.command()
@click.option('--config', '-c', type=click.Path(exists=True), help='Path to config file')
def start(config: Optional[str]):
    """Start the trading bot."""
    try:
        # Load configuration
        cfg = load_config(config)
        
        # Initialize components
        exchange = CoinbaseExchange(
            api_key=cfg.exchange.api_key,
            api_secret=cfg.exchange.api_secret,
            base_url=cfg.exchange.base_url
        )
        
        strategy = GridTradingStrategy(
            exchange=exchange,
            config=cfg.grid
        )
        
        # Start trading
        asyncio.run(strategy.start())
        
    except Exception as e:
        console.print(f"[red]Error starting bot:[/red] {e}")

@cli.command()
def status():
    """Show current bot status and performance."""
    # Implementation of status reporting
    pass

if __name__ == '__main__':
    cli()
EOL
}

# Create example usage scripts
create_example_files() {
    log_info "Creating example usage scripts..."
    
    # Create basic usage example
    cat > "$PROJECT_DIR/examples/basic_usage.py" << 'EOL'
"""
Basic Grid Trading Bot Usage Example

This script demonstrates how to set up and run the grid trading bot
with basic configuration.
"""

import asyncio
from decimal import Decimal

from grid_trading.config.loader import load_config
from grid_trading.exchanges.coinbase import CoinbaseExchange
from grid_trading.strategies.grid import GridTradingStrategy
from grid_trading.database.connection import DatabaseConnection
from grid_trading.monitoring.metrics import MetricsCollector

async def main():
    # Load configuration
    config = load_config('config.yaml')
    
    # Initialize exchange
    exchange = CoinbaseExchange(
        api_key=config.exchange.api_key,
        api_secret=config.exchange.api_secret,
        base_url=config.exchange.base_url
    )
    
    # Initialize database
    db = DatabaseConnection(
        f"sqlite:///{config.database.path}",
        pool_size=config.database.pool_size
    )
    
    # Initialize metrics collector
    metrics = MetricsCollector()
    
    # Create and start strategy
    strategy = GridTradingStrategy(
        exchange=exchange,
        config=config.grid
    )
    
    try:
        await strategy.initialize()
        await strategy.start()
        
        # Keep running until interrupted
        while True:
            await asyncio.sleep(1)
            
    except KeyboardInterrupt:
        print("\nStopping bot...")
        await strategy.stop()

if __name__ == '__main__':
    asyncio.run(main())
EOL
}

# Main execution
main() {
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "Error: Project directory $PROJECT_DIR does not exist!"
        exit 1
    fi
    
    create_exchange_files
    create_database_files
    create_strategy_files
    create_utility_files
    create_example_files
    
    log_info "Template files created successfully!"
    echo "
Next steps:
1. Review the created files and customize as needed
2. Update configuration in config.yaml
3. Run the example script to test the setup
4. Start implementing your trading strategy
"
}

main

