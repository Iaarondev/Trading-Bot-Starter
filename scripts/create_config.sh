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
ENVFILE
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_config "${1:-grid_trading_bot}"
fi
