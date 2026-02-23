import pandas as pd
import re

class DataCleaner:
    @staticmethod
    def clean_scheme_data(raw_data_list):
        """
        Takes raw scraped data, cleans it using Pandas, 
        and returns a structured list of dictionaries.
        """
        # Load into DataFrame for powerful manipulation
        df = pd.DataFrame(raw_data_list)

        # 1. Standardize Categories
        # This maps various scraped terms to your standardized labels
        category_map = {
            'Agriculture': 'Farmer',
            'Farming': 'Farmer',
            'Agri': 'Farmer',
            'Women': 'Woman',
            'Girls': 'Woman',
            'Students': 'Student',
            'Education': 'Student'
        }
        
        # Apply mapping and handle missing values
        df['category'] = df['category'].fillna('Others')
        df['category'] = df['category'].replace(category_map)
        
        # Ensure only allowed categories are used
        valid_cats = ['Farmer', 'Woman', 'Student', 'Others']
        df.loc[~df['category'].isin(valid_cats), 'category'] = 'Others'

        # 2. Text Scrubbing
        # Remove extra whitespace from titles
        df['title'] = df['title'].str.strip()
        
        # Remove HTML tags and extra whitespace from descriptions
        df['description'] = df['description'].apply(
            lambda x: re.sub(r'<[^>]*>', '', str(x)).strip() if x else "Government Scheme Details"
        )

        # 3. Deduplication
        # Keeps only the first instance of a scheme if the title matches exactly
        df = df.drop_duplicates(subset=['title'])

        # FINAL RETURN - Only one return statement at the very end
        return df.to_dict('records')