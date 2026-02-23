import logging
from datetime import datetime
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)


class ValidationPipeline:
    """Validate data before sending to database"""
    
    def process_item(self, item, spider):
        required_fields = ["title", "state_name", "category_name"]
        
        for field in required_fields:
            if not item.get(field):
                raise ValueError(f"Missing required field: {field}")
        
        # Clean data
        item["title"] = item["title"].strip()[:200]
        item["state_name"] = item["state_name"].strip()[:50]
        item["category_name"] = item["category_name"].strip()[:50]
        
        return item


class SupabasePipeline:
    """Insert/update schemes in Supabase with production-level error handling"""
    
    def __init__(self):
        self.supabase_url = os.getenv("SUPABASE_URL")
        self.supabase_key = os.getenv("SUPABASE_ANON_KEY")
        self.client = None
        self.inserted_count = 0
        self.updated_count = 0
        self.error_count = 0

    def open_spider(self, spider):
        """Initialize Supabase connection"""
        try:
            self.client = create_client(self.supabase_url, self.supabase_key)
            logger.info("✅ Supabase connection established")
        except Exception as e:
            logger.error(f"❌ Failed to connect to Supabase: {str(e)}")
            raise

    def process_item(self, item, spider):
        """INSERT scheme into database, silently skip duplicates"""
        try:
            # Prepare data for insert
            data = {
                "title": item["title"],
                "state_name": item["state_name"],
                "category_name": item["category_name"],
                "description": item.get("description", ""),
                "benefits": item.get("benefits", ""),
                "apply_link": item.get("apply_link"),
                "is_central": item.get("is_central", False),
                "source_url": item.get("source_url", ""),
            }
            
            logger.debug(f"📤 Attempting insert for: {item['title'][:50]}...")
            
            # INSERT - let database handle duplicates via unique constraint
            response = self.client.table("schemes").insert(data).execute()
            
            # Check if data was actually inserted
            if response and response.data and len(response.data) > 0:
                scheme_id = response.data[0].get("id")
                self.inserted_count += 1
                logger.info(f"✅ Inserted: {item['title'][:50]}... (ID: {scheme_id})")
            
            return item
            
        except Exception as e:
            error_msg = str(e)
            
            # Check if it's a duplicate key error (unique constraint violation)
            if "unique" in error_msg.lower() or "duplicate" in error_msg.lower() or "23505" in error_msg or "409" in error_msg:
                logger.debug(f"⏭️  Skipped (duplicate): {item['title'][:50]}")
                return item
            
            # Other errors - these are REAL errors
            self.error_count += 1
            logger.error(f"❌ INSERT FAILED: {item.get('title')[:50]}: {type(e).__name__}: {error_msg[:200]}")
            # Log full error for debugging
            import traceback
            logger.debug(f"Full error: {traceback.format_exc()}")
            # Don't raise - continue scraping
            return item

    def close_spider(self, spider):
        """Log final statistics"""
        logger.info("\n" + "="*80)
        logger.info("🏁 SPIDER SUMMARY")
        logger.info("="*80)
        logger.info(f"✅ Inserted/Updated: {self.inserted_count}")
        logger.info(f"❌ Errors: {self.error_count}")
        logger.info("="*80)