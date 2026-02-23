import scrapy
from scrapy_playwright.page import PageMethod
from datetime import datetime
import requests
from urllib.parse import urlparse

class OfficialSchemeSpider(scrapy.Spider):
    """Production-ready spider for scraping government schemes from all 31 categories"""
    name = "official_schemes"
    
    CATEGORIES = {
        "1": "General Services", "2": "Education and Learning", "3": "Health and Wellness",
        "4": "Children's Health and Immunisation", "5": "Social Welfare", "6": "Disease and Conditions",
        "7": "Health Care Providers and Access", "8": "Health Promotion", "9": "Medicine, Vaccines and Health Products",
        "10": "Mental Health", "11": "Sports", "12": "Workplace Health and Safety",
        "13": "Electricity, Water and Local Services", "14": "Money and Taxes", "15": "Jobs",
        "16": "Career Information", "17": "Employees", "18": "Employers",
        "19": "Employment Exchanges and Jobs", "20": "Retirement", "21": "Working Conditions, Health and Safety",
        "22": "Justice, Law and Grievances", "23": "Travel and Tourism", "24": "Business and Self-employed",
        "25": "Births, Deaths, Marriages and Child Care", "26": "Pension and Benefits", "27": "Transport and Infrastructure",
        "28": "Citizenship, Visas & Passports", "29": "Agriculture, Rural and Environment", "30": "Science, IT and Communications",
        "31": "Youth, Sports and Culture",
    }

    def start_requests(self):
        """Generate requests for all 31 categories with pagination"""
        self.logger.info(f"\n{'='*70}")
        self.logger.info(f"🚀 Starting spider - processing 31 categories with pagination")
        self.logger.info(f"{'='*70}\n")
        
        for cat_id in sorted(self.CATEGORIES.keys(), key=int):
            category_name = self.CATEGORIES.get(cat_id, "General Services")
            # Start with page 1, pagination will be handled in parse_with_pagination
            url = f"https://services.india.gov.in/service/listing?cat_id={cat_id}&ln=en&page=1"
            
            self.logger.info(f"🚀 Starting category {cat_id}: {category_name}")
            
            yield scrapy.Request(
                url,
                meta={
                    "playwright": True,
                    "playwright_page_methods": [
                        PageMethod("wait_for_load_state", "domcontentloaded", timeout=120000),
                        PageMethod("wait_for_timeout", 3000),
                        PageMethod("wait_for_load_state", "networkidle", timeout=120000),
                        PageMethod("wait_for_timeout", 2000),
                    ],
                    "category": category_name,
                    "cat_id": cat_id,
                    "page": 1,
                },
                callback=self.parse,
                dont_filter=True,
            )

    def parse(self, response):
        """Parse government schemes from listing page and follow detail links"""
        category = response.meta.get("category", "General Services")
        cat_id = response.meta.get("cat_id", "1")
        
        # Get all list items (schemes are typically in li or divs)
        schemes = response.css("li")
        
        self.logger.info(f"📄 Category: {category} (ID: {cat_id}) | Found {len(schemes)} total items")
        scheme_count = 0

        # Parse each scheme and follow its detail page for real apply link
        for idx, item in enumerate(schemes, 1):
            try:
                # Extract title from various possible locations
                title = (
                    item.css("strong a::text").get() or
                    item.css("strong::text").get() or
                    item.css("h3 a::text").get() or
                    item.css("h2 a::text").get() or
                    item.css("a::text").get()
                )
                
                # Extract link to scheme detail page
                link = (
                    item.css("strong a::attr(href)").get() or
                    item.css("a::attr(href)").get() or
                    item.css("h3 a::attr(href)").get()
                )
                
                # Extract description from listing
                desc = (
                    item.css("p::text").get() or
                    item.css(".description::text").get() or
                    item.css(".summary::text").get()
                )
                
                if title and title.strip():
                    title_clean = title.strip()
                    
                    # Skip very short titles (likely not schemes)
                    if len(title_clean) < 5:
                        continue
                    
                    # Skip known navigation/footer items
                    if title_clean in [
                        "Skip to main content", "हिन्दी", "Help", "Feedback", "Contact us",
                        "Home", "About Us", "Terms and Conditions", "All Categories",
                        "Link to us", "RSS Feeds", "Website Policy", "Site Map", "Visitor Summary",
                        "Contact", "FAQ", "Search", "Menu", "Navigation", "Footer",
                        "Privacy", "Disclaimer", "Accessibility", "Sitemap", "Subscribe"
                    ]:
                        continue
                    
                    state = self.detect_state(title_clean)
                    is_central = state == "Central"
                    
                    # Build scheme detail URL
                    scheme_detail_url = None
                    if link:
                        scheme_detail_url = response.urljoin(link)
                    
                    # Follow the detail page to extract real apply link
                    if scheme_detail_url:
                        yield scrapy.Request(
                            scheme_detail_url,
                            meta={
                                "playwright": True,
                                "playwright_page_methods": [
                                    PageMethod("wait_for_load_state", "domcontentloaded", timeout=60000),
                                    PageMethod("wait_for_timeout", 1500),
                                ],
                                "title": title_clean,
                                "state_name": state,
                                "is_central": is_central,
                                "category_name": category,
                                "description": desc.strip() if desc else f"Apply for {category} services online.",
                                "listing_page": response.url,
                            },
                            callback=self.parse_scheme_detail,
                            dont_filter=True,
                            errback=self.errback_scheme_detail,
                        )
                        scheme_count += 1
                    else:
                        # No detail link, yield with fallback apply_link
                        apply_link = f"https://services.india.gov.in/service/listing?cat_id={cat_id}&ln=en"
                        
                        scheme_data = {
                            "title": title_clean,
                            "state_name": state,
                            "category_name": category,
                            "description": desc.strip() if desc else f"Apply for {category} services online.",
                            "benefits": "Financial and social assistance as per department norms.",
                            "apply_link": apply_link,
                            "apply_link_type": "listing_page",
                            "link_status": "unknown",
                            "is_central": is_central,
                            "scraped_at": datetime.now().isoformat(),
                            "source_url": response.url,
                            "source_attribution": "services.india.gov.in",
                            "link_verified_at": None,
                            "confidence_score": 2,
                        }
                        
                        yield scheme_data
                        scheme_count += 1
                        
                        if is_central:
                            self.logger.info(f"  ✅ [CENTRAL] {title_clean[:55]} (no detail link)")
                        else:
                            self.logger.info(f"  ✅ [STATE] {state[:15]:15} | {title_clean[:45]} (no detail link)")
                    
            except Exception as e:
                self.logger.debug(f"  ⚠️  Error parsing item {idx}: {str(e)}")
                continue
        
        self.logger.info(f"✅ Finished category {cat_id} (Page {response.meta.get('page', 1)}) | Following {scheme_count} detail pages")
        
        # Check for pagination - look for next page button or link
        next_page_url = (
            response.css("a.next::attr(href)").get() or
            response.css("a[rel='next']::attr(href)").get() or
            response.css("li.next a::attr(href)").get() or
            response.xpath("//a[contains(text(), 'Next')]/@href").get() or
            response.xpath("//a[contains(text(), 'next')]/@href").get()
        )
        
        # If next page exists and we haven't exceeded max pages per category, follow it
        current_page = response.meta.get("page", 1)
        if next_page_url and current_page < 15:  # CHANGED: 5 → 15 pages per category
            next_page = current_page + 1
            full_url = response.urljoin(next_page_url)
            
            self.logger.info(f"📄 Following pagination to page {next_page}...")
            
            yield scrapy.Request(
                full_url,
                meta={
                    "playwright": True,
                    "playwright_page_methods": [
                        PageMethod("wait_for_load_state", "domcontentloaded", timeout=120000),
                        PageMethod("wait_for_timeout", 2000),
                        PageMethod("wait_for_load_state", "networkidle", timeout=120000),
                        PageMethod("wait_for_timeout", 1000),
                    ],
                    "category": response.meta.get("category"),
                    "cat_id": response.meta.get("cat_id"),
                    "page": next_page,
                },
                callback=self.parse,
                dont_filter=True,
            )
        else:
            self.logger.info(f"✅ Completed category {cat_id} | All pages processed\n")

    def parse_scheme_detail(self, response):
        """
        Extract real application link from scheme detail page.
        Looking for: Apply now buttons, ministry portals, application forms.
        """
        title = response.meta.get("title", "Unknown Scheme")
        state = response.meta.get("state_name", "Central")
        is_central = response.meta.get("is_central", True)
        category = response.meta.get("category_name", "General Services")
        description = response.meta.get("description", "")
        listing_page = response.meta.get("listing_page", "")
        
        try:
            # Look for actual apply/link buttons
            apply_links = [
                response.css("a[href*='apply']::attr(href)").get(),
                response.css("a[href*='application']::attr(href)").get(),
                response.css("a[href*='portal']::attr(href)").get(),
                response.css("a[href*='register']::attr(href)").get(),
                response.css("button a::attr(href)").get(),
                response.xpath("//a[contains(text(), 'Apply')]/@href").get(),
                response.xpath("//a[contains(text(), 'apply')]/@href").get(),
                response.xpath("//a[contains(text(), 'Apply Now')]/@href").get(),
                response.xpath("//a[contains(text(), 'Online Application')]/@href").get(),
                response.xpath("//a[contains(text(), 'Register')]/@href").get(),
                response.xpath("//a[contains(@class, 'apply')]/@href").get(),
                response.xpath("//a[contains(@class, 'btn')]/@href").get(),
            ]
            
            # Get first valid apply link
            apply_link = None
            for link in apply_links:
                if link:
                    apply_link = response.urljoin(link)
                    break
            
            # If no apply link found, use the detail page URL itself
            if not apply_link:
                apply_link = response.url
            
            # Extract full description from detail page
            full_desc = (
                response.css(".description::text").get() or
                response.css(".content::text").get() or
                response.css("article::text").get() or
                response.xpath("//p/text()").get() or
                description
            )
            
            # Validate link (check if it returns 200)
            link_status, link_verified_at = self.validate_link(apply_link)
            
            # Determine confidence score (1-5)
            confidence_score = self.calculate_confidence(apply_link, response.url)
            
            # Determine link type
            apply_link_type = self.determine_link_type(apply_link)
            
            # Extract eligibility if available
            eligibility = response.xpath("//h3[contains(text(), 'Eligibility')]/following-sibling::*/text()").get() or "Check official portal for eligibility"
            
            scheme_data = {
                "title": title,
                "state_name": state,
                "category_name": category,
                "description": full_desc.strip() if full_desc else description,
                "eligibility": eligibility,
                "benefits": response.xpath("//h3[contains(text(), 'Benefits')]/following-sibling::*/text()").get() or "As per scheme guidelines",
                "apply_link": apply_link,
                "apply_link_type": apply_link_type,
                "link_status": link_status,
                "link_verified_at": link_verified_at,
                "is_central": is_central,
                "confidence_score": confidence_score,
                "scraped_at": datetime.now().isoformat(),
                "source_url": response.url,
                "source_attribution": "services.india.gov.in",
            }
            
            yield scheme_data
            
            if is_central:
                self.logger.info(f"  ✅ [CENTRAL] {title[:55]} → {apply_link_type} (Status: {link_status})")
            else:
                self.logger.info(f"  ✅ [STATE] {state[:15]:15} | {title[:45]} → {apply_link_type} ({link_status})")
                
        except Exception as e:
            self.logger.warning(f"  ⚠️  Error parsing scheme detail '{title}': {str(e)}")
            # Yield with fallback data
            scheme_data = {
                "title": title,
                "state_name": state,
                "category_name": category,
                "description": description,
                "benefits": "As per scheme guidelines",
                "apply_link": response.url,
                "apply_link_type": "detail_page",
                "link_status": "error",
                "link_verified_at": datetime.now().isoformat(),
                "is_central": is_central,
                "confidence_score": 2,
                "scraped_at": datetime.now().isoformat(),
                "source_url": listing_page,
                "source_attribution": "services.india.gov.in",
            }
            yield scheme_data

    def validate_link(self, url):
        """
        Validate if link is working (returns 200 status).
        Returns (status, verified_timestamp)
        """
        try:
            response = requests.head(url, timeout=5, allow_redirects=True)
            status = response.status_code
            
            if status == 200:
                return "working", datetime.now().isoformat()
            elif status in [301, 302, 307, 308]:
                return "redirect", datetime.now().isoformat()
            elif status == 404:
                return "not_found", datetime.now().isoformat()
            elif status == 403:
                return "forbidden", datetime.now().isoformat()
            elif status == 500:
                return "server_error", datetime.now().isoformat()
            else:
                return f"status_{status}", datetime.now().isoformat()
        except requests.Timeout:
            return "timeout", datetime.now().isoformat()
        except requests.ConnectionError:
            return "connection_error", datetime.now().isoformat()
        except Exception as e:
            return "unknown_error", datetime.now().isoformat()

    def determine_link_type(self, url):
        """Determine the type of link for better categorization"""
        url_lower = url.lower()
        
        if "apply" in url_lower or "application" in url_lower:
            return "direct_apply_portal"
        elif "register" in url_lower:
            return "registration_portal"
        elif "services.india.gov.in" in url_lower:
            return "india_gov_portal"
        elif ".gov.in" in url_lower:
            return "government_portal"
        elif any(domain in url_lower for domain in [".nic.in", ".ac.in", ".org.in"]):
            return "official_portal"
        else:
            return "scheme_detail_page"

    def calculate_confidence(self, apply_link, source_url):
        """
        Calculate confidence score (1-5) based on link reliability.
        5 = Direct government portal
        4 = Official apply link from gov.in
        3 = Detail page with potential apply info
        2 = Fallback listing page
        1 = Unknown/broken link
        """
        link_lower = apply_link.lower()
        
        if "apply" in link_lower and ".gov.in" in link_lower:
            return 5
        elif ".gov.in" in link_lower:
            return 4
        elif apply_link != source_url:
            return 3
        else:
            return 2

    def errback_scheme_detail(self, failure):
        """Handle errors when following scheme detail links"""
        request = failure.request
        self.logger.warning(f"  ⚠️  Failed to fetch detail page: {request.url} - {failure.value}")

    def detect_state(self, title):
        """
        Detect state from scheme title. Returns state name or 'Central' for national schemes.
        
        Priority:
        1. Central government keywords (national schemes visible to all)
        2. State-specific keywords (state schemes)
        3. Default to Central if no match found
        """
        
        # Central government keywords that indicate national/central schemes
        # These schemes are accessible to users from ALL states
        central_keywords = [
            "national", "central", "union", "all india", "india", "govt of india",
            "ministry", "pmjdy", "pm-kisan", "pradhan mantri", "pm", "atal", 
            "deen dayal", "ayushman bharat", "digital india", "startup india",
            "make in india", "skill india", "smart cities", "swachh bharat",
            "ujala", "led", "saubhagya", "kusum", "saksham", "csr"
        ]
        
        # State to canonical name mapping (28 states + 8 union territories)
        states_map = {
            "tamil nadu": "Tamil Nadu",
            "tn": "Tamil Nadu",
            "bihar": "Bihar",
            "br": "Bihar",
            "kerala": "Kerala",
            "kl": "Kerala",
            "goa": "Goa",
            "ga": "Goa",
            "delhi": "Delhi",
            "nd": "Delhi",
            "delhi ncr": "Delhi",
            "ncr": "Delhi",
            "delhincr": "Delhi",
            "gujarat": "Gujarat",
            "gj": "Gujarat",
            "maharashtra": "Maharashtra",
            "mh": "Maharashtra",
            "rajasthan": "Rajasthan",
            "rj": "Rajasthan",
            "uttar pradesh": "Uttar Pradesh",
            "up": "Uttar Pradesh",
            "west bengal": "West Bengal",
            "wb": "West Bengal",
            "karnataka": "Karnataka",
            "ka": "Karnataka",
            "telangana": "Telangana",
            "ts": "Telangana",
            "andhra pradesh": "Andhra Pradesh",
            "ap": "Andhra Pradesh",
            "punjab": "Punjab",
            "pb": "Punjab",
            "haryana": "Haryana",
            "hr": "Haryana",
            "himachal": "Himachal Pradesh",
            "himachal pradesh": "Himachal Pradesh",
            "hp": "Himachal Pradesh",
            "madhya pradesh": "Madhya Pradesh",
            "mp": "Madhya Pradesh",
            "chhattisgarh": "Chhattisgarh",
            "ct": "Chhattisgarh",
            "assam": "Assam",
            "as": "Assam",
            "tripura": "Tripura",
            "tr": "Tripura",
            "meghalaya": "Meghalaya",
            "ml": "Meghalaya",
            "manipur": "Manipur",
            "mn": "Manipur",
            "mizoram": "Mizoram",
            "mz": "Mizoram",
            "nagaland": "Nagaland",
            "nl": "Nagaland",
            "sikkim": "Sikkim",
            "sk": "Sikkim",
            "arunachal": "Arunachal Pradesh",
            "arunachal pradesh": "Arunachal Pradesh",
            "ar": "Arunachal Pradesh",
            "jammu": "Jammu & Kashmir",
            "kashmir": "Jammu & Kashmir",
            "j&k": "Jammu & Kashmir",
            "jk": "Jammu & Kashmir",
            "ladakh": "Ladakh",
            "puducherry": "Puducherry",
            "pu": "Puducherry",
            "chandigarh": "Chandigarh",
            "ch": "Chandigarh",
            "andaman": "Andaman & Nicobar",
            "lakshadweep": "Lakshadweep",
            "dadar": "Dadra & Nagar Haveli",
        }
        
        title_lower = title.lower()
        
        # Check if it's a central scheme
        
        for keyword in central_keywords:
            if keyword in title_lower:
                return "Central"
        
        # Check for state-specific keywords
        for state_key, state_name in states_map.items():
            if state_key in title_lower:
                return state_name
        
        # Default to Central
        return "Central"