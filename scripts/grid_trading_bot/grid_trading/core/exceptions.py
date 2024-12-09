class ExchangeError(Exception):
    """Base exception for exchange errors"""
    pass

class InsufficientFundsError(ExchangeError):
    """Raised when account has insufficient funds"""
    pass

class InvalidOrderError(ExchangeError):
    """Raised when order parameters are invalid"""
    pass
