"""Cache service for storing and retrieving cached data"""

from typing import Any, Optional
from datetime import datetime, timedelta
import json


class CacheService:
    """In-memory cache service"""
    
    _instance = None
    _cache = {}
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(CacheService, cls).__new__(cls)
            cls._instance._cache = {}
        return cls._instance
    
    def set(self, key: str, value: Any, ttl: int = 3600) -> None:
        """Set cache value with TTL"""
        expiry = datetime.utcnow() + timedelta(seconds=ttl)
        self._cache[key] = {
            "value": value,
            "expiry": expiry
        }
    
    def get(self, key: str) -> Optional[Any]:
        """Get cache value if not expired"""
        if key not in self._cache:
            return None
        
        cached = self._cache[key]
        if datetime.utcnow() > cached["expiry"]:
            del self._cache[key]
            return None
        
        return cached["value"]
    
    def delete(self, key: str) -> None:
        """Delete cache entry"""
        if key in self._cache:
            del self._cache[key]
    
    def clear(self) -> None:
        """Clear all cache"""
        self._cache.clear()
    
    def get_or_set(
        self, 
        key: str, 
        callback, 
        ttl: int = 3600
    ) -> Any:
        """Get from cache or call callback to set"""
        cached = self.get(key)
        if cached:
            return cached
        
        value = callback()
        self.set(key, value, ttl)
        return value


# Create singleton instance
cache_service = CacheService()
