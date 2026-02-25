"""Supabase service for database operations"""

import os
from datetime import datetime
from typing import List, Optional
from supabase import create_client
from app.models.scheme import Scheme
from app.models.user import User
from config.settings import settings


class SupabaseService:
    """Service for Supabase database operations"""
    
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SupabaseService, cls).__new__(cls)
            cls._instance._supabase = None
        return cls._instance
    
    @property
    def client(self):
        """Get or create Supabase client"""
        if self._supabase is None:
            self._supabase = create_client(
                settings.SUPABASE_URL,
                settings.SUPABASE_SERVICE_KEY
            )
        return self._supabase
    
    # ========== SCHEMES ==========
    
    def get_all_schemes(self) -> List[Scheme]:
        """Fetch all schemes from database"""
        try:
            response = self.client.table('schemes').select('*').execute()
            schemes = [Scheme(**item) for item in response.data]
            return schemes
        except Exception as e:
            raise Exception(f"Error fetching schemes: {str(e)}")
    
    def search_schemes(
        self, 
        query: str, 
        state: Optional[str] = None,
        category: Optional[str] = None,
        limit: int = 50
    ) -> List[Scheme]:
        """Search schemes by query, state, or category"""
        try:
            db_query = self.client.table('schemes').select('*')
            
            # Add filters
            if state:
                db_query = db_query.eq('state_name', state)
            if category:
                db_query = db_query.eq('category_name', category)
            
            # Search in title or description
            if query:
                # Use Supabase full-text search
                db_query = db_query.or_(
                    f"title.ilike.%{query}%,description.ilike.%{query}%,benefits.ilike.%{query}%"
                )
            
            response = db_query.limit(limit).execute()
            schemes = [Scheme(**item) for item in response.data]
            return schemes
        except Exception as e:
            raise Exception(f"Error searching schemes: {str(e)}")
    
    def get_schemes_by_state(self, state: str) -> List[Scheme]:
        """Get schemes for specific state"""
        try:
            # Central schemes + state-specific schemes
            response = self.client.table('schemes').select('*').or_(
                f"state_name.eq.{state},is_central.eq.true"
            ).execute()
            schemes = [Scheme(**item) for item in response.data]
            return schemes
        except Exception as e:
            raise Exception(f"Error fetching schemes by state: {str(e)}")
    
    def get_scheme_by_id(self, scheme_id: str) -> Optional[Scheme]:
        """Get single scheme by ID"""
        try:
            response = self.client.table('schemes').select('*').eq(
                'id', scheme_id
            ).single().execute()
            return Scheme(**response.data) if response.data else None
        except Exception as e:
            raise Exception(f"Error fetching scheme: {str(e)}")
    
    # ========== USERS ==========
    
    def get_user_profile(self, user_uuid: str) -> Optional[User]:
        """Get user profile"""
        try:
            response = self.client.table('users').select('*').eq(
                'uuid', user_uuid
            ).single().execute()
            return User(**response.data) if response.data else None
        except Exception:
            # User might not exist yet
            return None
    
    def create_or_update_user(
        self,
        user_uuid: str,
        gender: Optional[str] = None,
        age: Optional[int] = None,
        state: Optional[str] = None,
        occupation: Optional[str] = None
    ) -> User:
        """Create or update user profile"""
        try:
            user_data = {
                "uuid": user_uuid,
                "gender": gender,
                "age": age,
                "state": state,
                "occupation": occupation,
                "updated_at": datetime.utcnow().isoformat()
            }
            
            # Try to insert, if exists update
            response = self.client.table('users').upsert(user_data).execute()
            return User(**response.data[0]) if response.data else User(**user_data)
        except Exception as e:
            raise Exception(f"Error updating user: {str(e)}")
    
    # ========== BOOKMARKS ==========
    
    def bookmark_scheme(self, user_uuid: str, scheme_id: str) -> bool:
        """Save scheme for user"""
        try:
            bookmark_data = {
                "user_uuid": user_uuid,
                "scheme_id": scheme_id,
                "saved_at": datetime.utcnow().isoformat()
            }
            self.client.table('saved_schemes').upsert(bookmark_data).execute()
            return True
        except Exception as e:
            raise Exception(f"Error bookmarking scheme: {str(e)}")
    
    def remove_bookmark(self, user_uuid: str, scheme_id: str) -> bool:
        """Remove bookmarked scheme"""
        try:
            self.client.table('saved_schemes').delete().eq(
                'user_uuid', user_uuid
            ).eq('scheme_id', scheme_id).execute()
            return True
        except Exception as e:
            raise Exception(f"Error removing bookmark: {str(e)}")
    
    def get_saved_schemes(self, user_uuid: str) -> List[str]:
        """Get list of saved scheme IDs for user"""
        try:
            response = self.client.table('saved_schemes').select(
                'scheme_id'
            ).eq('user_uuid', user_uuid).execute()
            return [item['scheme_id'] for item in response.data]
        except Exception as e:
            raise Exception(f"Error fetching saved schemes: {str(e)}")


# Create singleton instance
supabase_service = SupabaseService()
