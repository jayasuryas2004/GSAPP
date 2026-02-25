# 🔐 GSAPP Security Setup - Production

**Status:** ✅ Production-Ready with Authenticated Access Only

---

## 🛡️ Security Features Implemented

### 1. **Environment Variables Protection**
- ✅ `.env` file is in `.gitignore` (NEVER committed to GitHub)
- ✅ `.env.example` shows required variables (no secrets)
- ✅ All credentials stored locally only
- ✅ Production: Use Supabase environment variables

### 2. **Row Level Security (RLS) - Authenticated Only**

All database tables now require **authentication**:

#### **Schemes Table:**
```
READ:   ✅ Authenticated users only
INSERT: ✅ Service Role only (backend)
UPDATE: ✅ Service Role only (backend)
DELETE: ❌ Disabled
```

#### **Users Table:**
```
READ:   ✅ Users can read own record
UPDATE: ✅ Users can update own record
DELETE: ❌ Disabled
```

#### **Saved_Schemes Table:**
```
READ:   ✅ Users can read own wishlist
INSERT: ✅ Users can save own schemes
DELETE: ✅ Users can remove own schemes
```

#### **Analytics Table:**
```
READ:   ✅ Authenticated users (view stats)
UPDATE: ✅ Service Role only (backend tracking)
DELETE: ❌ Disabled
```

---

## 🔑 Credential Management

### **Development (Local Machine)**
1. Create `.env` file (not in Git):
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_KEY=your-service-key
   ```

2. Use ANON_KEY for:
   - ✅ Mobile app (user operations)
   - ✅ Frontend queries (with RLS)

3. Use SERVICE_KEY for:
   - ✅ Backend only (scrapers, imports)
   - ✅ Data administration

### **Production (Deployment)**
1. **Never use `.env` files**
2. Set variables in deployment platform:
   - Vercel: Settings → Environment Variables
   - Docker: Environment secrets
   - AWS Lambda: Secrets Manager

### **GitHub Protection**
```bash
# What's committed:
✅ .env.example (template only, no secrets)
✅ .gitignore (prevents .env upload)
✅ migrations.sql (database schema)

# What's NOT committed:
❌ .env (contains secrets)
❌ spvenv/ (virtual environment)
❌ __pycache__/ (cache)
```

---

## 🚀 User Authentication Flow

### **Mobile App Access:**
```
1. User opens app
2. App creates/loads anon user (UUID stored locally)
3. App uses ANON_KEY for queries
4. RLS policies check:
   - Can read: All schemes (public info)
   - Can save: Own wishlist only
   - Can update: Own preferences only

Example Query (with RLS enforcement):
SELECT * FROM schemes WHERE state_name = 'Tamil Nadu'
→ ✅ ALLOWED (authenticated user)

SELECT * FROM schemes WHERE is_deleted = true
→ ❌ BLOCKED (no delete policy)
```

### **Backend/Scraper Access:**
```
1. Backend uses SERVICE_KEY
2. Can INSERT/UPDATE schemes
3. Can manage analytics
4. Can run maintenance tasks

Note: SERVICE_KEY never goes to GitHub or app
```

---

## 🔒 Before Pushing to GitHub

**Checklist:**
- [ ] `.env` file exists locally (contains your credentials)
- [ ] `.env` is in `.gitignore`
- [ ] `.env.example` is in Git (no secrets, just keys)
- [ ] Database migrations applied (with authenticated RLS)
- [ ] No API keys visible in code
- [ ] No placeholder credentials in source files

**Verify with:**
```bash
git status                  # Should NOT show .env
cat .gitignore | grep .env  # Should see ".env"
grep -r "sk_live_" .        # Should find nothing
```

---

## 📋 Production Deployment Checklist

1. **Supabase Setup:**
   ```
   ✅ Create Supabase project
   ✅ Run migrations.sql (creates RLS policies)
   ✅ Get ANON_KEY (for app)
   ✅ Get SERVICE_KEY (for backend only)
   ```

2. **Mobile App Setup:**
   ```
   ✅ Add SUPABASE_URL to pubspec.yaml
   ✅ Add SUPABASE_ANON_KEY to pubspec.yaml
   ✅ Initialize Supabase client in app
   ```

3. **Backend Setup:**
   ```
   ✅ Set SUPABASE_SERVICE_KEY in environment
   ✅ Deploy importers with SERVICE_KEY access
   ✅ Deploy scrapers with SERVICE_KEY access
   ```

4. **GitHub:**
   ```
   ✅ Push code with .env excluded
   ✅ Add .env.example for reference
   ✅ Document in README how to set up
   ```

---

## ⚠️ Security Best Practices

### **DO:**
✅ Use `.env.example` for template  
✅ Store real credentials in secure vaults (1Password, AWS Secrets, etc.)  
✅ Rotate keys regularly  
✅ Use SERVICE_KEY only on backend  
✅ Check `.gitignore` before every commit  
✅ Review Git history for accidental commits: `git log -p | grep -A5 -B5 "SUPABASE"`  

### **DON'T:**
❌ Commit `.env` file  
❌ Share API keys in chat/email  
❌ Use same key for dev and production  
❌ Log credentials to console  
❌ Hardcode keys in source code  
❌ Use anon key for backend operations  

---

## 🆘 If You Accidentally Commit Secrets

1. **Remove from Git history:**
   ```bash
   git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch .env' -- --all
   ```

2. **Revoke credentials immediately:**
   - Go to Supabase → Settings → API Keys
   - Regenerate both ANON_KEY and SERVICE_KEY
   - Update `.env` locally

3. **Force push:**
   ```bash
   git push origin --force-with-lease
   ```

4. **Tell team:** Let anyone with access know credentials were compromised

---

## 📞 Security Contacts

- **Supabase Support:** https://supabase.com/support
- **GitHub Security:** https://github.com/security
- **Report Security Issue:** security@example.com (if applicable)

---

**Last Updated:** February 23, 2026  
**Status:** ✅ Production Secure
