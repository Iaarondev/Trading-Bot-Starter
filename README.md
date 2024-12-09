# Grid Trading Bot

A robust, modular cryptocurrency grid trading bot implementation that automates the grid trading strategy across various exchanges.

## Overview

Grid trading is a strategy that places multiple buy and sell orders at regular price intervals above and below a set price, creating a grid of orders. This bot automates this strategy, handling order placement, tracking, and rebalancing.

### Key Features

- **Modular Design**: Easily extensible to support multiple exchanges
- **Real-time Monitoring**: Track performance and trading activities
- **Risk Management**: Built-in safety features and customizable risk parameters
- **Data Persistence**: SQLAlchemy-based database for reliable trade tracking
- **Asynchronous Architecture**: Efficient handling of multiple operations
- **Comprehensive Logging**: Detailed activity logging for monitoring and debugging

## Project Structure

```
grid_trading_bot/
├── grid_trading/
│   ├── core/               # Core interfaces and base classes
│   ├── exchanges/          # Exchange-specific implementations
│   ├── database/           # Database models and utilities
│   ├── strategies/         # Trading strategy implementations
│   ├── monitoring/         # Performance monitoring tools
│   └── utils/             # Shared utilities
├── tests/                  # Test suite
│   ├── unit/              # Unit tests
│   └── integration/       # Integration tests
├── docs/                   # Documentation
├── examples/              # Example implementations
└── scripts/               # Utility scripts
```

## Prerequisites

- Python 3.8 or higher
- pip (Python package installer)
- Virtual environment tool (venv)
- Exchange API credentials (currently supports Coinbase)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/grid_trading_bot.git
cd grid_trading_bot
```

2. Create and activate a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Copy the example configuration:
```bash
cp .env.example .env
cp config.yaml.example config.yaml
```

5. Update configuration files with your settings.

## Configuration

### Environment Variables (.env)
```
EXCHANGE_API_KEY=your_api_key
EXCHANGE_API_SECRET=your_api_secret
LOG_LEVEL=INFO
DATABASE_URL=sqlite:///grid_trading.db
```

### Trading Parameters (config.yaml)
```yaml
exchange:
  api_key: ${EXCHANGE_API_KEY}
  api_secret: ${EXCHANGE_API_SECRET}
  base_url: https://api.coinbase.com
  rate_limit: 30

grid:
  trading_pair: BTC-USD
  grid_size: 10
  grid_spread: 0.02
  base_order_size: 0.001
  check_interval: 60

database:
  path: grid_trading.db
  pool_size: 5
```

## Usage

### Basic Usage

```python
from grid_trading.config import load_config
from grid_trading.exchanges.coinbase import CoinbaseExchange
from grid_trading.strategies.grid import GridTradingStrategy

async def main():
    # Load configuration
    config = load_config('config.yaml')
    
    # Initialize exchange
    exchange = CoinbaseExchange(
        api_key=config.exchange.api_key,
        api_secret=config.exchange.api_secret
    )
    
    # Create and start strategy
    strategy = GridTradingStrategy(exchange, config.grid)
    await strategy.start()

if __name__ == '__main__':
    asyncio.run(main())
```

### Command Line Interface

Start the bot:
```bash
python -m grid_trading start --config config.yaml
```

Check status:
```bash
python -m grid_trading status
```

## Development

### Setting Up Development Environment

1. Install development dependencies:
```bash
pip install -r requirements-dev.txt
```

2. Set up pre-commit hooks:
```bash
pre-commit install
```

### Running Tests

Run the full test suite:
```bash
pytest tests/
```

Run with coverage:
```bash
pytest tests/ --cov=grid_trading --cov-report=html
```

### Code Style

This project uses:
- Black for code formatting
- isort for import sorting
- flake8 for linting
- mypy for type checking

Run all style checks:
```bash
./scripts/lint.sh
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

Please ensure you:
- Write tests for new functionality
- Follow the existing code style
- Update documentation as needed
- Add yourself to CONTRIBUTORS.md

## Safety Considerations

- **Test thoroughly** in a sandbox environment first
- Start with small trade amounts
- Monitor the bot regularly
- Keep API keys secure
- Set appropriate stop-loss levels
- Understand the risks involved in automated trading

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to all contributors
- Inspired by various grid trading implementations
- Built with Python's excellent async libraries

## Support

- Create an issue for bug reports or feature requests
- Check existing issues and documentation first
- Join our community Discord for discussions

## Disclaimer

This bot is for educational purposes only. Use at your own risk. Cryptocurrency trading carries significant risks, and past performance does not guarantee future results.