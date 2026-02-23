"""
JSON Schemes Importer - Phase 1
Load 34 manually curated schemes into Supabase

Usage:
    python importers/import_json_schemes.py
"""

import json
import os
from typing import Dict, List
import sys

from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables
load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))


class JSONSchemesImporter:
    """Import Phase 1 JSON schemes into Supabase database"""
    
    def __init__(self):
        """Initialize Supabase client"""
        self.supabase_url = os.getenv("SUPABASE_URL")
        self.supabase_key = os.getenv("SUPABASE_KEY") or os.getenv("SUPABASE_ANON_KEY")
        
        if not self.supabase_url or not self.supabase_key:
            print("❌ SUPABASE_URL or SUPABASE_ANON_KEY not set in .env")
            sys.exit(1)
        
        self.client: Client = create_client(self.supabase_url, self.supabase_key)
        self.stats = {"total": 0, "inserted": 0, "errors": 0}
    
    def read_json_schemes(self) -> List[Dict]:
        """Read schemes from schemes.json file"""
        json_file = os.path.join(os.path.dirname(__file__), '..', 'schemes.json')
        
        if not os.path.exists(json_file):
            print(f"❌ File not found: {json_file}")
            sys.exit(1)
        
        with open(json_file, 'r', encoding='utf-8') as f:
            schemes = json.load(f)
        
        print(f"📖 Loaded {len(schemes)} schemes from JSON")
        return schemes
    
    def transform_scheme(self, json_scheme: Dict) -> Dict:
        """Transform JSON scheme to database schema"""
        state = json_scheme.get("state", "Central")
        if state == "All India":
            state = "Central"
        
        age_range = json_scheme.get("eligibility", {}).get("ageRange", [None, None]) or [None, None]
        
        return {
            "title": json_scheme.get("title", {}).get("en", ""),
            "title_ta": json_scheme.get("title", {}).get("ta", ""),
            "short_description": json_scheme.get("shortDescription", {}).get("en", ""),
            "short_description_ta": json_scheme.get("shortDescription", {}).get("ta", ""),
            "description": json_scheme.get("shortDescription", {}).get("en", ""),
            "description_ta": json_scheme.get("shortDescription", {}).get("ta", ""),
            "benefits": json_scheme.get("benefits", {}).get("en", ""),
            "benefits_ta": json_scheme.get("benefits", {}).get("ta", ""),
            "category_name": json_scheme.get("category", "General"),
            "state_name": state,
            "is_central": state == "Central",
            "apply_link": json_scheme.get("applicationUrl", ""),
            "source_url": json_scheme.get("applicationUrl", ""),
            "agency": json_scheme.get("agency", ""),
            "badge": json_scheme.get("badge"),
            "highlight": json_scheme.get("highlight", ""),
            "image_url": json_scheme.get("imageUrl", ""),
            "eligibility_age_min": age_range[0] if len(age_range) > 0 else None,
            "eligibility_age_max": age_range[1] if len(age_range) > 1 else None,
            "eligibility_income_max": json_scheme.get("eligibility", {}).get("incomeMax"),
            "eligibility_gender": json_scheme.get("eligibility", {}).get("gender", "any"),
            "last_date": json_scheme.get("lastDate"),
            "source": "json",
        }
    
    def insert_scheme(self, scheme: Dict) -> bool:
        """Insert scheme into database"""
        try:
            self.client.table("schemes").upsert(scheme).execute()
            return True
        except Exception as e:
            print(f"  ⚠️  Error: '{scheme['title']}': {str(e)[:50]}")
            self.stats["errors"] += 1
            return False
    
    def import_schemes(self):
        """Main import process"""
        print("\n" + "="*70)
        print("🚀 PHASE 1: JSON SCHEMES IMPORTER (Curated)")
        print("="*70 + "\n")
        
        schemes = self.read_json_schemes()
        self.stats["total"] = len(schemes)
        
        print(f"📝 Importing {len(schemes)} schemes...\n")
        
        for idx, json_scheme in enumerate(schemes, 1):
            scheme = self.transform_scheme(json_scheme)
            if self.insert_scheme(scheme):
                self.stats["inserted"] += 1
            
            title = scheme["title"][:45]
            print(f"  {idx}/{len(schemes)} ✅ {title}...")
        
        print("\n" + "="*70)
        print(f"✅ Imported: {self.stats['inserted']} schemes")
        print(f"❌ Errors: {self.stats['errors']}")
        print("="*70)


if __name__ == "__main__":
    importer = JSONSchemesImporter()
    importer.import_schemes()
