"""
Database Connection Management

This module handles database connection pooling and session management.
It provides a context manager for safe database operations.

Features:
- Connection pooling
- Session management
- Migration support
- Error handling
"""

import contextlib
from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool

class DatabaseConnection:
    """Manages database connections and sessions."""
    
    def __init__(
        self,
        connection_url: str,
        pool_size: int = 5,
        max_overflow: int = 10
    ):
        """Initialize database connection manager."""
        self.engine = create_engine(
            connection_url,
            poolclass=QueuePool,
            pool_size=pool_size,
            max_overflow=max_overflow,
            pool_pre_ping=True
        )
        self.SessionLocal = sessionmaker(
            autocommit=False,
            autoflush=False,
            bind=self.engine
        )
    
    @contextlib.contextmanager
    def get_session(self) -> Generator[Session, None, None]:
        """Provides a transactional scope around a series of operations."""
        session = self.SessionLocal()
        try:
            yield session
            session.commit()
        except Exception:
            session.rollback()
            raise
        finally:
            session.close()
