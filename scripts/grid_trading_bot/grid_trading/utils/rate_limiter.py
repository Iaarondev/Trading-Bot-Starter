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
