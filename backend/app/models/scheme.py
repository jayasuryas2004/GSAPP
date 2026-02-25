"""Scheme model"""

from typing import Optional
from datetime import date


class Scheme:
    """Scheme data model from Supabase"""
    
    def __init__(
        self,
        id: str,
        title: str,
        description: str,
        short_description: Optional[str],
        category_name: str,
        state_name: str,
        apply_link: str,
        is_central: bool,
        benefits: Optional[str] = None,
        agency: Optional[str] = None,
        badge: Optional[str] = None,
        image_url: Optional[str] = None,
        eligibility_age_min: Optional[int] = None,
        eligibility_age_max: Optional[int] = None,
        eligibility_income_max: Optional[int] = None,
        last_date: Optional[date] = None,
        **kwargs
    ):
        self.id = id
        self.title = title
        self.description = description
        self.short_description = short_description
        self.category_name = category_name
        self.state_name = state_name
        self.apply_link = apply_link
        self.is_central = is_central
        self.benefits = benefits
        self.agency = agency
        self.badge = badge
        self.image_url = image_url
        self.eligibility_age_min = eligibility_age_min
        self.eligibility_age_max = eligibility_age_max
        self.eligibility_income_max = eligibility_income_max
        self.last_date = last_date
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "short_description": self.short_description,
            "category_name": self.category_name,
            "state_name": self.state_name,
            "apply_link": self.apply_link,
            "is_central": self.is_central,
            "benefits": self.benefits,
            "agency": self.agency,
            "badge": self.badge,
            "image_url": self.image_url,
            "eligibility_age_min": self.eligibility_age_min,
            "eligibility_age_max": self.eligibility_age_max,
            "eligibility_income_max": self.eligibility_income_max,
            "last_date": self.last_date,
        }
