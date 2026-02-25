"""User model"""

from typing import Optional


class User:
    """User data model"""
    
    def __init__(
        self,
        uuid: str,
        gender: Optional[str] = None,
        age: Optional[int] = None,
        state: Optional[str] = None,
        occupation: Optional[str] = None,
        created_at: Optional[str] = None,
        updated_at: Optional[str] = None,
        **kwargs
    ):
        self.uuid = uuid
        self.gender = gender
        self.age = age
        self.state = state
        self.occupation = occupation
        self.created_at = created_at
        self.updated_at = updated_at
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            "uuid": self.uuid,
            "gender": self.gender,
            "age": self.age,
            "state": self.state,
            "occupation": self.occupation,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
        }
