"""Scheme schemas for request/response validation"""

from typing import Optional
from datetime import date
from pydantic import BaseModel


class SchemeBase(BaseModel):
    """Base scheme schema"""
    title: str
    description: Optional[str] = None
    short_description: Optional[str] = None
    category_name: str
    state_name: str
    apply_link: str
    is_central: bool = False


class SchemeResponse(SchemeBase):
    """Scheme response schema"""
    id: str
    benefits: Optional[str] = None
    agency: Optional[str] = None
    badge: Optional[str] = None
    image_url: Optional[str] = None
    eligibility_age_min: Optional[int] = None
    eligibility_age_max: Optional[int] = None
    eligibility_income_max: Optional[int] = None
    last_date: Optional[date] = None
    
    class Config:
        from_attributes = True


class SchemeListResponse(BaseModel):
    """List of schemes response"""
    total: int
    schemes: list[SchemeResponse]
    
    class Config:
        from_attributes = True


class SchemeSearchRequest(BaseModel):
    """Scheme search request"""
    query: str
    state: Optional[str] = None
    category: Optional[str] = None
    limit: int = 50


class SchemeSearchResponse(BaseModel):
    """Scheme search response"""
    query: str
    total: int
    schemes: list[SchemeResponse]
