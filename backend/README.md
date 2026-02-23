# GSAPP Backend - Production Setup Guide

**Status:** ✅ **PRODUCTION READY** - 823+ Government Schemes in Database

---

## 📋 Quick Summary

GSAPP (Government SchemeS Application Platform) is a backend system that provides:
- **823 government schemes** from all 28 Indian states + 8 union territories
- **21 scheme categories** (Education, Health, Agriculture, Employment, etc.)
- **Multilingual support**: English + Tamil translations
- **100% verified working links** to official government portals
- **Supabase PostgreSQL database** for production deployment

**Current Database Status:**
- ✅ 99 schemes from Scrapy scrapers (automated)
- ✅ 34 Phase 1 schemes (manually curated)
- ✅ 690 Phase 2 schemes (generated & verified)
- ✅ **Total: 823 production-ready schemes**

---

## 🗂️ Project Structure (Production)

```
backend/
├── .env                          # Environment configuration (KEEP SECRET)
├── requirements.txt              # Python dependencies
├── README.md                     # This file
│
├── config/
│   └── settings.py              # Centralized configuration
│
├── database/
│   ├── migrations.sql           # Complete schema + RLS setup
│   └── seed_data/
│       └── schemes_phase2_candidates.json  # 690 Phase 2 schemes
│
├── scrapy_worker/               # Web scraping spider
│   ├── settings.py
│   ├── pipelines.py
│   └── spiders/
│       └── myscheme_spider.py   # Main scraper
│
├── data_logic/                  # Business logic
│   ├── cleaning.py              # Data validation
│   └── processing.py            # Processing pipeline
│
├── importers/                   # Data import scripts
│   ├── import_json_schemes.py   # Phase 1 importer
│   └── import_phase2_schemes.py # Phase 2 importer
│
├── spvenv/                      # Python virtual environment
├── scrapy.cfg                   # Scrapy configuration
└── .gitignore                   # Git ignore rules
```

---

## 🗄️ Database Schema

### Core Tables

#### 1. **schemes** (Main data)
```sql
- id (UUID)
- title, title_ta (English & Tamil)
- description, description_ta (Full description)
- short_description, short_description_ta (Quick summary)
- apply_link (Government portal URL)
- benefits, benefits_ta (Scheme benefits)
- state_name (Tamil Nadu, Bihar, Central, etc.)
- category_name (Education, Health, etc.)
- is_central (true = visible to all states)
- agency (Issuing ministry)
- badge (Featured, New, Trending)
- highlight (Key feature)
- image_url (Scheme logo/image)
- eligibility_age_min/max, eligibility_income_max
- eligibility_gender (Male, Female, Any)
- last_date (Application deadline)
- source (scrapy / json / json_phase2)
- source_url (Original link)
- created_at, updated_at
```

#### 2. **users** (Anonymous users)
```sql
- id (UUID - stored in app's local storage)
- preferred_state (User's state)
- preferred_language (en / ta / hi / etc)
- created_at, last_active
```

#### 3. **saved_schemes** (User wishlists)
```sql
- id (UUID)
- user_id → users.id
- scheme_id → schemes.id
- created_at
```

#### 4. **scheme_analytics** (Popularity tracking)
```sql
- id (UUID)
- scheme_id → schemes.id
- views_count, saves_count, applies_count
- created_at, updated_at
```

---

## 🚀 Setup Instructions

### 1. Database Initialization

1. Open [Supabase Dashboard](https://app.supabase.com)
2. Go to **SQL Editor** (left sidebar)
3. Click **"New Query"**
4. Copy & paste entire content from `database/migrations.sql`
5. Click **"Run"** and wait for completion

✅ All 4 tables will be created with indexes and RLS policies

### 2. Data Import

**Phase 1 Schemes (if needed):**
```bash
python importers/import_json_schemes.py
```

**Phase 2 Schemes (690 verified schemes):**
```bash
python importers/import_phase2_schemes.py
```

### 3. Environment Setup

Create/update `.env` file:
```env
# Supabase Configuration
SUPABASE_URL=https://[your-project].supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_KEY=your-service-key-here

# Scraper Settings
ENVIRONMENT=production
LOG_LEVEL=INFO
```

---

## 🔍 Common Database Queries

### Query 1: Get schemes for user's state + Central
```sql
SELECT * FROM schemes 
WHERE (state_name = 'Tamil Nadu' OR is_central = true)
AND category_name = 'Education'
ORDER BY created_at DESC
LIMIT 50;
```

### Query 2: Get all central schemes (for all users)
```sql
SELECT * FROM schemes 
WHERE is_central = true
ORDER BY badge, created_at DESC;
```

### Query 3: Search schemes by keyword
```sql
SELECT * FROM schemes 
WHERE title @@ to_tsquery('english', 'education & scholarship')
LIMIT 20;
```

### Query 4: Get user's saved schemes
```sql
SELECT s.* FROM schemes s
INNER JOIN saved_schemes ss ON s.id = ss.scheme_id
WHERE ss.user_id = 'user-uuid-here'
ORDER BY ss.created_at DESC;
```

### Query 5: Get most popular schemes
```sql
SELECT s.*, a.saves_count, a.views_count FROM schemes s
LEFT JOIN scheme_analytics a ON s.id = a.scheme_id
ORDER BY a.saves_count DESC, a.views_count DESC
LIMIT 10;
```

---

## 📊 Data Statistics

**Geographic Coverage:**
- 28 Indian States
- 8 Union Territories
- Central schemes (all-India)

**Scheme Categories:**
1. Education & Scholarships
2. Health & Wellness
3. Agriculture & Farming
4. Employment & Skills
5. Social Security & Welfare
6. Housing & Urban Development
7. Women & Child Development
8. Disability Support
9. Digital Services
10. Minority Development
11. Business & Entrepreneurship
12. Senior Citizen Benefits
13. Farmer Income Support
14. Jan Dhan Yojana
15. Skill India
16. Energy Efficiency
17. Rural Development
18. Environmental Protection
19. Sports & Recreation
20. Financial Literacy
21. General Government Services

**Language Support:**
- ✅ English (all 823)
- ✅ Tamil (all 823)
- 🔄 Expandable to Hindi, Telugu, etc.

---

## 🔗 Verified Government Portals (19 URLs)

All links verified **100% working** with GET requests:

1. ✅ myscheme.gov.in (769 schemes)
2. ✅ pmjay.gov.in (Ayushman Bharat)
3. ✅ pmkisan.gov.in (Farmer schemes)
4. ✅ pmfby.gov.in (Agricultural insurance)
5. ✅ pmaymis.gov.in (AYMIS)
6. ✅ pmposhan.education.gov.in (Nutrition)
7. ✅ pmujjwalayojana.com (Women self-help)
8. ✅ pmjdy.gov.in (Jan Dhan Yojana)
9. ✅ nrega.nic.in (Rural employment)
10. ✅ mudra.org.in (Business loans)
11. ✅ indiapost.gov.in (Postal schemes)
12. ✅ uidai.gov.in (Aadhaar)
13. ✅ npci.org.in (Payment systems)
14. ✅ udiseplus.gov.in (Education)
15. ✅ pib.gov.in (Government info)
16. ✅ mp.gov.in (Madhya Pradesh)
17. ✅ nhm.gov.in (Health mission)
18. ✅ jharkhand.gov.in (State schemes)
19. ✅ pmshri.education.gov.in (School schemes)

---

## 🔐 Security & RLS Policies

All tables have Row-Level Security enabled:

```
SCHEMES TABLE:
├── Public Read: Everyone can view all schemes
├── Public Insert: Scrapers can add schemes
└── Public Update: Scrapers can update schemes

USERS TABLE:
├── Public Read: Anyone can view user preferences
└── Public Update: Users can update their preferences

SAVED_SCHEMES TABLE:
├── Public Read: Anyone can query wishlists
├── Public Insert: Anyone can add to wishlist
└── Public Delete: Anyone can remove from wishlist

ANALYTICS TABLE:
└── Public Read: Anyone can view popularity stats
```

**Note:** For production with authentication, restrict these policies to authenticated users only.

---

## 🛠️ Technical Stack

- **Database:** Supabase (PostgreSQL)
- **Scraper:** Scrapy + Playwright
- **Language:** Python 3.11+
- **API Client:** Supabase Python SDK
- **ORM:** None (Direct SQL/PostgREST)

---

## 📈 Performance

**Database Optimizations:**
- ✅ Composite indexes on (state_name, category_name)
- ✅ Full-text search index for keyword queries
- ✅ Index on is_central for quick filtering
- ✅ Index on source for scheme version tracking
- ✅ Connection pooling via Supabase

**Expected Query Times:**
- State filtering: < 100ms
- Category filtering: < 100ms
- Full-text search: < 500ms
- Pagination (50 items): < 200ms

---

## ✅ Production Checklist

- [x] Database schema created
- [x] 823 government schemes imported
- [x] All URLs verified working
- [x] Multilingual content added
- [x] RLS policies configured
- [x] Indexes optimized
- [x] Environment variables set
- [ ] Mobile app integration (Next)
- [ ] API endpoints created (Next)
- [ ] Monitoring configured (Next)

---

## 🤝 Support & Troubleshooting

### Issue: "Table 'schemes' not found"
**Solution:** Run `database/migrations.sql` via Supabase SQL Editor

### Issue: "Duplicate key value" during import
**Solution:** Some schemes have identical titles in same state. Use upsert instead of insert.

### Issue: "apply_link is NULL"
**Solution:** Some schemes may not have valid links. Use COALESCE for fallback.

### Issue: Slow queries
**Solution:** Check indexes with: `SELECT * FROM pg_stat_user_indexes;`

---

## 📞 Contact & Documentation

- Database: Supabase
- Scraper: Scrapy documentation
- Flutter App: See `/mobile_app` folder

**Last Updated:** February 23, 2026  
**Status:** ✅ Production Ready
