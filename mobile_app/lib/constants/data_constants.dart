/// Data Constants
/// Static lists and enum-like data that doesn't change during runtime
class DataConstants {
  // Gender Options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Prefer Not to Say',
  ];

  // Occupations
  static const List<String> occupationOptions = [
    'Farmer',
    'Student',
    'Laborer',
    'Business Owner',
    'Employee',
    'Homemaker',
    'Retired',
    'Other',
  ];

  // Indian States (28) + Union Territories (8)
  static const List<String> indianStates = [
    // States
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    // Union Territories
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Lakshadweep',
    'Delhi',
    'Puducherry',
    'Ladakh',
    'Jammu and Kashmir',
  ];

  // Scheme Categories
  static const List<String> schemeCategories = [
    'Agriculture',
    'Education',
    'Finance',
    'Healthcare',
    'Housing',
    'Employment',
    'Women',
    'Senior Citizen',
    'Disability',
    'Transportation',
    'Social Security',
    'Other',
  ];

  // Scheme Types
  static const List<String> schemeTypes = [
    'Central',
    'State-Specific',
    'Both',
  ];

  // Age Ranges for Filtering
  static const Map<String, List<int>> ageRanges = {
    '18-25': [18, 25],
    '26-35': [26, 35],
    '36-50': [36, 50],
    '51-65': [51, 65],
    '65+': [65, 100],
  };

  // Benefit Types
  static const List<String> benefitTypes = [
    'Cash Grant',
    'Loan',
    'Subsidy',
    'Free Training',
    'Insurance',
    'Healthcare',
    'Education Support',
    'Employment',
    'Housing',
    'Other',
  ];

  // Application Status
  static const List<String> applicationStatus = [
    'Open',
    'Closed',
    'Upcoming',
    'On Hold',
  ];

  // Sorting Options
  static const Map<String, String> sortingOptions = {
    'best_match': 'Best Match',
    'latest': 'Latest Added',
    'most_popular': 'Most Popular',
    'highest_benefit': 'Highest Benefit',
    'alphabetical': 'A to Z',
  };

  // Filter Options
  static const List<String> filterOptions = [
    'My Profile',
    'Central Schemes',
    'State Schemes',
    'Easy to Apply',
    'High Benefit Amount',
  ];

  // Sort Duration for Cache
  static const Map<String, int> timeDurations = {
    'today': 0,
    'this_week': 7,
    'this_month': 30,
    'this_year': 365,
  };

  // Match Score Thresholds
  static const Map<String, int> matchScoreThresholds = {
    'perfect': 85,
    'good': 65,
    'possible': 40,
  };

  // Ministry List (Common Indian Government Ministries)
  static const List<String> indianMinistries = [
    'Ministry of Agriculture & Farmers Welfare',
    'Ministry of Education',
    'Ministry of Finance',
    'Ministry of Health & Family Welfare',
    'Ministry of Housing & Urban Affairs',
    'Ministry of Labour & Employment',
    'Ministry of Rural Development',
    'Ministry of Women & Child Development',
    'Ministry of Social Justice & Empowerment',
    'Ministry of Skill Development & Entrepreneurship',
    'Ministry of Micro, Small & Medium Enterprises',
    'Ministry of Commerce & Industry',
    'Ministry of External Affairs',
    'Other',
  ];

  // Empty State Messages
  static const Map<String, String> emptyStateMessages = {
    'no_schemes': 'No schemes found. Try adjusting your filters.',
    'no_saved': 'You haven\'t saved any schemes yet.',
    'no_search_results': 'No results found for your search.',
    'offline': 'You\'re offline. Showing cached schemes.',
    'error': 'Unable to load schemes. Please try again.',
  };
}
