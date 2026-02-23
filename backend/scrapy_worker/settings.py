import os
from dotenv import load_dotenv

load_dotenv()

BOT_NAME = 'scrapy_worker'
SPIDER_MODULES = ['scrapy_worker.spiders']
NEWSPIDER_MODULE = 'scrapy_worker.spiders'

# ============================================================================
# 1. PLAYWRIGHT CONFIGURATION (Browser Automation)
# ============================================================================
DOWNLOAD_HANDLERS = {
    "http": "scrapy_playwright.handler.ScrapyPlaywrightDownloadHandler",
    "https": "scrapy_playwright.handler.ScrapyPlaywrightDownloadHandler",
}

TWISTED_REACTOR = "twisted.internet.asyncioreactor.AsyncioSelectorReactor"

PLAYWRIGHT_BROWSER_TYPE = "chromium"

# ============================================================================
# 2. ANTI-BOT EVASION & TIMEOUTS
# ============================================================================
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
DOWNLOAD_TIMEOUT = 180  # 3 minutes
CONCURRENT_REQUESTS = 1
CONCURRENT_REQUESTS_PER_DOMAIN = 1

# ============================================================================
# 3. SPEED OPTIMIZATION (Block unnecessary resources)
# ============================================================================
# Block images, fonts, media to speed up crawling by 5x
PLAYWRIGHT_ABORT_REQUEST = lambda req: req.resource_type in ["image", "font", "media", "beacon", "ad"]

# ============================================================================
# 4. ROBOT RULES & DELAYS
# ============================================================================
ROBOTSTXT_OBEY = False
DOWNLOAD_DELAY = 2
RANDOMIZE_DOWNLOAD_DELAY = True

# ============================================================================
# 5. RETRY LOGIC (For resilience)
# ============================================================================
RETRY_TIMES = 3
RETRY_HTTP_CODES = [500, 502, 503, 504, 408, 429]

# ============================================================================
# 6. PIPELINES (Data processing)
# ============================================================================
ITEM_PIPELINES = {
    'pipelines.ValidationPipeline': 300,
    'pipelines.SupabasePipeline': 400,
}

# ============================================================================
# 7. LOGGING
# ============================================================================
LOG_LEVEL = 'INFO'
LOG_FORMAT = '%(asctime)s [%(name)s] %(levelname)s: %(message)s'

# ============================================================================
# 8. DATABASE CONFIGURATION (Supabase)
# ============================================================================
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")

# ============================================================================
# 9. AUTO-THROTTLE (For handling rate limits)
# ============================================================================
AUTOTHROTTLE_ENABLED = True
AUTOTHROTTLE_START_DELAY = 3
AUTOTHROTTLE_MAX_DELAY = 60
AUTOTHROTTLE_TARGET_CONCURRENCY = 1.0
AUTOTHROTTLE_DEBUG = True