"""
GSAPP Backend Configuration
Centralized settings for production
"""

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# ============================================================================
# SUPABASE CONFIGURATION
# ============================================================================

SUPABASE_URL = os.getenv('SUPABASE_URL', '')
SUPABASE_ANON_KEY = os.getenv('SUPABASE_ANON_KEY', '')
SUPABASE_SERVICE_KEY = os.getenv('SUPABASE_SERVICE_KEY', '')

if not SUPABASE_URL or not SUPABASE_ANON_KEY:
    raise ValueError("❌ SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env")

# ============================================================================
# ENVIRONMENT
# ============================================================================

ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
DEBUG = ENVIRONMENT == 'development'

# ============================================================================
# SCRAPY CONFIGURATION
# ============================================================================

SCRAPY_SETTINGS_MODULE = 'scrapy_worker.settings'
PLAYWRIGHT_BROWSER_TYPE = os.getenv('PLAYWRIGHT_BROWSER_TYPE', 'chromium')

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================

DB_CONFIG = {
    'url': SUPABASE_URL,
    'key': SUPABASE_ANON_KEY,
    'timeout': 30,
    'pool_size': 10,
    'max_overflow': 20,
}

# ============================================================================
# SCRAPER TARGETS
# ============================================================================

TARGET_URLS = {
    'welfare': 'https://services.india.gov.in/service/listing?cat_id=5&ln=en',
    'education': 'https://services.india.gov.in/service/listing?cat_id=2&ln=en',
    'myscheme': 'https://www.myscheme.gov.in/',
}

# ============================================================================
# IMPORT CONFIGURATION
# ============================================================================

IMPORT_CONFIG = {
    'batch_size': 100,
    'ignore_duplicates': True,
    'upsert_on_conflict': True,
}

# ============================================================================
# DATA PATHS
# ============================================================================

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEED_DATA_DIR = os.path.join(BASE_DIR, 'database', 'seed_data')
MIGRATIONS_DIR = os.path.join(BASE_DIR, 'database')

# ============================================================================
# LOGGING
# ============================================================================

LOGGING_CONFIG = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'simple',
        },
        'file': {
            'class': 'logging.FileHandler',
            'filename': os.path.join(BASE_DIR, 'app.log'),
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': LOG_LEVEL,
    },
}

# ============================================================================
# SECURITY
# ============================================================================

CORS_ALLOWED_ORIGINS = [
    'http://localhost:3000',
    'http://localhost:8080',
    'http://localhost:5173',  # Vite
    'https://*.vercel.app',
    'https://*.netlify.app',
]

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '0.0.0.0',
]

# ============================================================================
# FEATURE FLAGS
# ============================================================================

FEATURES = {
    'enable_scraper': True,
    'enable_analytics': True,
    'enable_cache': False,
    'debug_mode': DEBUG,
}


def validate_config():
    """Validate configuration is correct"""
    if not SUPABASE_URL or not SUPABASE_ANON_KEY:
        raise ValueError("❌ Missing Supabase credentials in .env")
    
    if not os.path.exists(SEED_DATA_DIR):
        print(f"⚠️  Warning: Seed data directory not found: {SEED_DATA_DIR}")
    
    if not os.path.exists(MIGRATIONS_DIR):
        print(f"⚠️  Warning: Migrations directory not found: {MIGRATIONS_DIR}")
    
    print("✅ Configuration validated successfully")


if __name__ == '__main__':
    validate_config()
    print(f"Environment: {ENVIRONMENT}")
    print(f"Debug: {DEBUG}")
    print(f"Supabase URL: {SUPABASE_URL}")
