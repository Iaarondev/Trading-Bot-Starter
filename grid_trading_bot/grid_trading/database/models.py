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
