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
