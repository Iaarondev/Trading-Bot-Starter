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
