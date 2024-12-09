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
