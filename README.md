# Grid Trading Bot Template

A modular, extensible cryptocurrency grid trading bot template with built-in safety features and exchange integrations.

## Features

- Modular architecture for easy customization
- Multiple exchange support (Coinbase, Binance)
- Grid trading strategy implementation
- Risk management and position tracking
- Database integration with PostgreSQL
- Docker support for deployment
- Comprehensive testing setup
- CI/CD with GitHub Actions

## Quick Start

```bash
# Clone repository
git clone [your-repo-url]

# Run setup script
./setup.sh my_trading_bot

# Configure settings
cp .env.example .env
nano .env

# Start with Docker
docker-compose up -d
```

## Project Structure

```
grid_trading/
├── core/          # Core interfaces and base classes
├── exchanges/     # Exchange implementations
├── strategies/    # Trading strategies
├── database/     # Database models and operations
├── utils/        # Utility functions
└── monitoring/   # Performance metrics
```

## Setup Scripts

`setup.sh [project_name] [options]`
- `--force`: Override existing directory
- `--minimal`: Create minimal setup

Individual component scripts:
- `create_core.sh`: Trading interfaces
- `create_database.sh`: Database setup
- `create_exchanges.sh`: Exchange implementations
- `create_strategies.sh`: Trading strategies
- `create_utils.sh`: Utility functions
- `create_monitoring.sh`: Metrics collection

## Development

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest tests/
```

## Safety Features

- API rate limiting
- Position size limits
- Error handling & recovery
- Transaction logging
- Performance monitoring

## Contributing

1. Fork repository
2. Create feature branch
3. Implement changes
4. Add tests
5. Submit PR

## License

MIT

## Security

- Never commit API keys
- Use environment variables
- Implement position limits
- Enable monitoring alerts