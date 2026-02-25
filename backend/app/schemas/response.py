"""API Response schemas"""

from typing import Generic, TypeVar, Optional, Any
from pydantic import BaseModel

T = TypeVar("T")


class APIResponse(BaseModel, Generic[T]):
    """Standard API response wrapper"""
    success: bool
    message: str
    data: Optional[T] = None
    error: Optional[str] = None
    
    class Config:
        from_attributes = True


class ErrorResponse(BaseModel):
    """Error response"""
    success: bool = False
    message: str
    error: str
    detail: Optional[dict] = None
