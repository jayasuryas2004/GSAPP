"""User schemas for request/response validation"""

from typing import Optional
from pydantic import BaseModel


class UserProfileRequest(BaseModel):
    """User profile update request"""
    gender: Optional[str] = None
    age: Optional[int] = None
    state: Optional[str] = None
    occupation: Optional[str] = None


class UserProfileResponse(BaseModel):
    """User profile response"""
    uuid: str
    gender: Optional[str] = None
    age: Optional[int] = None
    state: Optional[str] = None
    occupation: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    
    class Config:
        from_attributes = True


class SavedSchemeRequest(BaseModel):
    """Save scheme request"""
    scheme_id: str


class SavedSchemeResponse(BaseModel):
    """Saved scheme response"""
    user_uuid: str
    scheme_id: str
    saved_at: str
