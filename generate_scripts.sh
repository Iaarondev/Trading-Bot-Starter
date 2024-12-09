#!/bin/bash

# Create script directory and navigate to it
mkdir -p scripts
cd scripts

# Common utilities
cat > "common.sh" << 'EOL'
#!/bin/bash
set -euo pipefail

export GREEN='\033[0;32m'
export RED='\033[0;31m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'
export NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

check_dependencies() {
    local deps=("python3" "pip" "git" "docker")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "$dep is required but not installed"
            exit 1
        fi
    done
}

validate_python_version() {
    local version=$(python3 -c 'import sys; print(f"{sys.version_info[0]}{sys.version_info[1]:02d}")')
    if (( version < 308 )); then
        log_error "Python 3.8+ required (found $(python3 -V))"
        exit 1
    fi
}

handle_error() {
    log_error "Error on line $1"
    exit 1
}

trap 'handle_error ${LINENO}' ERR
EOL

# Core components
cat > "create_core.sh" << 'EOL'
#!/bin/bash
source ./common.sh

create_core() {
    local project_dir=$1
    ensure_directory "$project_dir/grid_trading/core"

    # Create exchange interface
    cat > "$project_dir/grid_trading/core/exchange.py" << 'PYFILE'
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
PYFILE

    # Create exceptions
    cat > "$project_dir/grid_trading/core/exceptions.py" << 'PYFILE'
class ExchangeError(Exception):
    """Base exception for exchange errors"""
    pass

class InsufficientFundsError(ExchangeError):
    """Raised when account has insufficient funds"""
    pass

class InvalidOrderError(ExchangeError):
    """Raised when order parameters are invalid"""
    pass
PYFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_core "${1:-grid_trading_bot}"
fi
EOL

# Exchange implementations
cat > "create_exchanges.sh" << 'EOL'
#!/bin/bash
source ./common.sh

create_exchanges() {
    local project_dir=$1
    ensure_directory "$project_dir/grid_trading/exchanges"

    # Create Coinbase implementation
    cat > "$project_dir/grid_trading/exchanges/coinbase.py" << 'PYFILE'
"""Coinbase Exchange Implementation"""
import asyncio
import hmac
import hashlib
import time
from decimal import Decimal
import aiohttp
from typing import Dict

from grid_trading.core.exchange import ExchangeInterface, OrderBook
from grid_trading.core.exceptions import ExchangeError
from grid_trading.utils.rate_limiter import RateLimiter

class CoinbaseExchange(ExchangeInterface):
    def __init__(self, api_key: str, api_secret: str):
        self.api_key = api_key
        self.api_secret = api_secret
        self.session = aiohttp.ClientSession()
        self.rate_limiter = RateLimiter(30, 1.0)

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.session.close()

    async def get_order_book(self, symbol: str) -> OrderBook:
        async with self.rate_limiter:
            # Implementation
            pass

    async def place_limit_order(
        self, symbol: str, side: str,
        price: Decimal, quantity: Decimal
    ) -> str:
        async with self.rate_limiter:
            # Implementation
            pass
PYFILE

    # Create Binance implementation
    cat > "$project_dir/grid_trading/exchanges/binance.py" << 'PYFILE'
"""Binance Exchange Implementation"""
from grid_trading.core.exchange import ExchangeInterface

class BinanceExchange(ExchangeInterface):
    # Implementation
    pass
PYFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_exchanges "${1:-grid_trading_bot}"
fi
EOL

# Database components
cat > "create_database.sh" << 'EOL'
#!/bin/bash
source ./common.sh

create_database() {
    local project_dir=$1
    ensure_directory "$project_dir/grid_trading/database"

    # Create models
    cat > "$project_dir/grid_trading/database/models.py" << 'PYFILE'
from datetime import datetime
from decimal import Decimal
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class GridConfig(Base):
    __tablename__ = 'grid_configs'
    id = Column(Integer, primary_key=True)
    symbol = Column(String, nullable=False)
    grid_size = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
PYFILE

    # Create connection manager
    cat > "$project_dir/grid_trading/database/connection.py" << 'PYFILE'
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from contextlib import contextmanager

class DatabaseConnection:
    def __init__(self, url: str):
        self.engine = create_engine(url)
        self.SessionLocal = sessionmaker(bind=self.engine)

    @contextmanager
    def session(self):
        session = self.SessionLocal()
        try:
            yield session
            session.commit()
        except:
            session.rollback()
            raise
        finally:
            session.close()
PYFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_database "${1:-grid_trading_bot}"
fi
EOL

# Strategies
cat > "create_strategies.sh" << 'EOL'
#!/bin/bash
source ./common.sh

create_strategies() {
    local project_dir=$1
    ensure_directory "$project_dir/grid_trading/strategies"

    # Create grid strategy
    cat > "$project_dir/grid_trading/strategies/grid.py" << 'PYFILE'
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
PYFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_strategies "${1:-grid_trading_bot}"
fi
EOL

# Utils
cat > "create_utils.sh" << 'EOL'
#!/bin/bash
source ./common.sh

create_utils() {
    local project_dir=$1
    ensure_directory "$project_dir/grid_trading/utils"

    # Create rate limiter
    cat > "$project_dir/grid_trading/utils/rate_limiter.py" << 'PYFILE'
"""Rate Limiter Implementation"""
import asyncio
import time

class RateLimiter:
    def __init__(self, max_requests: int, time_window: float):
        self.max_requests = max_requests
        self.time_window = time_window
        self.tokens = max_requests
        self.last_update = time.monotonic()
        self.lock = asyncio.Lock()

    async def acquire(self):
        async with self.lock:
            now = time.monotonic()
            time_passed = now - self.last_update
            self.tokens = min(
                self.max_requests,
                self.tokens + (time_passed * self.max_requests / self.time_window)
            )
            self.last_update = now

            if self.tokens < 1:
                await asyncio.sleep(0.1)
            else:
                self.tokens -= 1
PYFILE

    # Create config validator
    cat > "$project_dir/grid_trading/utils/validation.py" << 'PYFILE'
"""Configuration Validation"""
from decimal import Decimal
from typing import Dict, Any
from pydantic import BaseModel, validator

class GridConfig(BaseModel):
    symbol: str
    grid_size: int
    upper_price: Decimal
    lower_price: Decimal
    quantity_per_order: Decimal

    @validator('grid_size')
    def validate_grid_size(cls, v):
        if v < 2:
            raise ValueError("Grid size must be at least 2")
        return v
PYFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_utils "${1:-grid_trading_bot}"
fi
EOL

# Configuration
cat > "create_config.sh" << 'EOL'
#!/bin/bash
source ./common.sh

create_config() {
    local project_dir=$1

    # Create config.yaml
    cat > "$project_dir/config.yaml" << 'YAMLFILE'
exchange:
  api_key: your_api_key
  api_secret: your_api_secret
  base_url: https://api.coinbase.com

grid:
  symbol: BTC-USD
  grid_size: 10
  upper_price: 50000
  lower_price: 40000
  quantity_per_order: 0.001

database:
  url: sqlite:///grid_trading.db
  pool_size: 5
YAMLFILE

    # Create .env.example
    cat > "$project_dir/.env.example" << 'ENVFILE'
EXCHANGE_API_KEY=your_api_key
EXCHANGE_API_SECRET=your_api_secret
DATABASE_URL=sqlite:///grid_trading.db
LOG_LEVEL=INFO
YAMLFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_config "${1:-grid_trading_bot}"
fi
EOL

# Main setup script
cat > "setup.sh" << 'EOL'
#!/bin/bash
source ./common.sh

PROJECT_NAME=${1:-grid_trading_bot}
FORCE_CREATE=false
MINIMAL_SETUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force) FORCE_CREATE=true; shift ;;
        --minimal) MINIMAL_SETUP=true; shift ;;
        *) PROJECT_NAME="$1"; shift ;;
    esac
done

main() {
    log_info "Starting project setup: $PROJECT_NAME"
    
    check_dependencies
    validate_python_version
    
    if [[ -d "$PROJECT_NAME" && "$FORCE_CREATE" == false ]]; then
        log_error "Directory exists. Use --force to override."
        exit 1
    fi
    
    ensure_directory "$PROJECT_NAME"
    
    for script in create_*.sh; do
        if [[ -x "$script" ]]; then
            log_info "Running $script"
            ./"$script" "$PROJECT_NAME"
        fi
    done
    
    log_info "Setup complete!"
}

main
EOL

# Make all scripts executable
chmod +x *.sh

echo "Setup scripts generated successfully"