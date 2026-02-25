"""
GSAPP Backend Configuration
Centralized settings using Pydantic for type safety and validation
"""

from pydantic_settings import BaseSettings
from pydantic import ConfigDict
from typing import Optional
from pathlib import Path

# Get the absolute path to .env file
ENV_FILE = Path(__file__).parent.parent / '.env'


class Settings(BaseSettings):
    """Settings using Pydantic BaseSettings for validation"""
    model_config = ConfigDict(extra='ignore', env_file=str(ENV_FILE), case_sensitive=True)
    
    # Supabase Configuration
    SUPABASE_URL: str = ''
    SUPABASE_SERVICE_KEY: str = ''
    
    # Environment & Debug
    ENVIRONMENT: str = 'development'
    DEBUG: bool = False
    LOG_LEVEL: str = 'INFO'
    PORT: int = 8000
    
    # API Configuration
    APP_NAME: str = 'GSAPP'
    APP_VERSION: str = '1.0.0'
    API_V1_PREFIX: str = '/api/v1'
    HOST: str = '0.0.0.0'
    WORKERS: int = 1
    
    # Cache Configuration
    CACHE_TTL_SECONDS: int = 3600
    CACHE_MAX_ITEMS: int = 1000
    CACHE_SCHEMES_TTL: int = 3600
    
    # CORS Configuration
    ALLOWED_ORIGINS: list = [
        'http://localhost:3000',
        'http://localhost:8000',
        'http://localhost:8080',
        'http://10.0.2.2:8000',
        'http://10.0.2.2:3000',
    ]
    
    # Logging
    LOG_FILE: Optional[str] = 'app.log'
    
    # Security
    API_KEY: Optional[str] = None
    
    def __init__(self, **data):
        super().__init__(**data)
        
        # Set DEBUG based on ENVIRONMENT
        if not hasattr(self, 'DEBUG') or not self.DEBUG:
            self.DEBUG = self.ENVIRONMENT == 'development'
        
        # Validate required settings
        if not self.SUPABASE_URL:
            raise ValueError('[ERROR] SUPABASE_URL must be set in .env')
        if not self.SUPABASE_SERVICE_KEY:
            raise ValueError('[ERROR] SUPABASE_SERVICE_KEY must be set in .env')


# Create singleton settings instance
settings = Settings()
