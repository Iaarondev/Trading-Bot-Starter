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
