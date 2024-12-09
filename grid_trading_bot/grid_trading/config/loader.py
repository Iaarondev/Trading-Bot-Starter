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
