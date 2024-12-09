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
