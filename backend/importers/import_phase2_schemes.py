"""
JSON Schemes Importer - Phase 2
Load 690 auto-generated & verified schemes into Supabase

Usage:
    python importers/import_phase2_schemes.py
"""

import json
import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_ANON_KEY')

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Load schemes from seed data
print('📥 Loading Phase 2 schemes from seed data...')
schemes_file = os.path.join(os.path.dirname(__file__), '..', 'database', 'seed_data', 'schemes_phase2_candidates.json')
with open(schemes_file, 'r', encoding='utf-8') as f:
    schemes_data = json.load(f)

print(f'📊 Total schemes to import: {len(schemes_data)}')
print()

# Prepare data (map JSON fields to database columns)
print('📋 Mapping JSON fields to database schema...')
schemes_for_db = []
for scheme in schemes_data:
    state = scheme.get('state', 'Central')
    if state == 'All India':
        state = 'Central'
    
    age_range = scheme.get('eligibility', {}).get('ageRange', [None, None]) or [None, None]
    
    db_scheme = {
        'title': scheme.get('title', {}).get('en', ''),
        'short_description': scheme.get('shortDescription', {}).get('en', ''),
        'short_description_ta': scheme.get('shortDescription', {}).get('ta', ''),
        'description': scheme.get('shortDescription', {}).get('en', ''),
        'description_ta': scheme.get('shortDescription', {}).get('ta', ''),
        'title_ta': scheme.get('title', {}).get('ta', ''),
        'benefits': scheme.get('benefits', {}).get('en', ''),
        'benefits_ta': scheme.get('benefits', {}).get('ta', ''),
        'category_name': scheme.get('category', 'General'),
        'state_name': state,
        'is_central': state == 'Central',
        'apply_link': scheme.get('applicationUrl', ''),
        'source_url': scheme.get('applicationUrl', ''),
        'agency': scheme.get('agency', ''),
        'badge': scheme.get('badge'),
        'highlight': scheme.get('highlight', ''),
        'image_url': scheme.get('imageUrl', ''),
        'eligibility_age_min': age_range[0] if len(age_range) > 0 else None,
        'eligibility_age_max': age_range[1] if len(age_range) > 1 else None,
        'eligibility_income_max': scheme.get('eligibility', {}).get('incomeMax'),
        'eligibility_gender': scheme.get('eligibility', {}).get('gender', 'any'),
        'last_date': scheme.get('lastDate'),
        'source': 'json_phase2',
    }
    schemes_for_db.append(db_scheme)

print(f'✅ Prepared {len(schemes_for_db)} schemes for insertion')
print()

# Insert in batches
print('📤 Inserting schemes into database...')
print('=' * 70)

batch_size = 100
total_inserted = 0
failed_count = 0

for i in range(0, len(schemes_for_db), batch_size):
    batch_num = (i // batch_size) + 1
    batch = schemes_for_db[i:i + batch_size]
    
    try:
        response = supabase.table('schemes').insert(batch).execute()
        total_inserted += len(batch)
        print(f'✅ Batch {batch_num}/8: {len(batch)} schemes inserted')
    except Exception as e:
        failed_count += len(batch)
        error_msg = str(e)[:80]
        print(f'❌ Batch {batch_num}/8: FAILED - {error_msg}')

print('=' * 70)
print()
print('📊 IMPORT SUMMARY:')
print(f'   ✅ Successfully inserted: {total_inserted} schemes')
print(f'   ❌ Failed: {failed_count} schemes')
print(f'   📈 Total in database: {total_inserted}')
print()
print('✅ Phase 2 schemes imported successfully!')
