-- Additional Government Schemes Data
-- Tamil Nadu and Central Government welfare schemes (APPENDED to existing schemes.sql)
-- NOTE: Do NOT include DELETE statements - this is appended to existing data

-- ============================================================================
-- ADDITIONAL TAMIL NADU STATE SCHEMES
-- ============================================================================

INSERT OR REPLACE INTO schemes (id, name_tamil, name_english, description_tamil, description_english, level, department, application_url, is_active) VALUES
('tn-amma-unavagam', 'அம்மா உணவகம்', 'Amma Unavagam',
'ஏழைகளுக்கு மிகக் குறைந்த விலையில் சத்தான உணவு வழங்கும் அரசு உணவகம். இட்லி ரூ.1, சாம்பார் சாதம் ரூ.5, தயிர் சாதம் ரூ.3.',
'Government canteen providing nutritious food at subsidized prices for the poor. Idli at Rs.1, Sambar Rice at Rs.5, Curd Rice at Rs.3.',
'state', 'Municipal Administration Department', 'https://www.tn.gov.in', 1),

('tn-free-laptop', 'இலவச மடிக்கணினி திட்டம்', 'Free Laptop Scheme',
'அரசு பள்ளிகளில் 11ம் வகுப்பு மற்றும் 12ம் வகுப்பு மாணவர்களுக்கு இலவச மடிக்கணினி வழங்கும் திட்டம்.',
'Free laptop distribution scheme for students in Class 11 and 12 of government schools.',
'state', 'School Education Department', 'https://www.tnschools.gov.in', 1),

('tn-uzhavar-sandhai', 'உழவர் சந்தை', 'Uzhavar Sandhai',
'விவசாயிகள் நேரடியாக நுகர்வோருக்கு காய்கறிகள் மற்றும் பழங்களை விற்கும் அரசு சந்தை. இடைத்தரகர் இல்லை.',
'Government market where farmers sell vegetables and fruits directly to consumers without middlemen.',
'state', 'Agriculture Marketing Department', 'https://www.agrimarketing.tn.gov.in', 1),

('tn-cm-breakfast', 'முதலமைச்சர் காலை உணவு திட்டம்', 'CM Breakfast Scheme',
'அரசு பள்ளி மாணவர்களுக்கு ஊட்டச்சத்து மிக்க இலவச காலை உணவு. 1 முதல் 5ம் வகுப்பு வரை.',
'Free nutritious breakfast for government school students from Class 1 to 5.',
'state', 'Social Welfare Department', 'https://www.tnsocialwelfare.tn.gov.in', 1),

('tn-transgender-welfare', 'திருநங்கை நலத்திட்டம்', 'Transgender Welfare Scheme',
'திருநங்கைகளுக்கு நிதி உதவி, கல்வி உதவித்தொகை, இலவச அறுவை சிகிச்சை மற்றும் வாழ்வாதார உதவி.',
'Financial assistance, educational scholarships, free surgery, and livelihood support for transgender persons.',
'state', 'Social Welfare Department', 'https://www.tnsocialwelfare.tn.gov.in', 1),

('tn-differently-abled-pension', 'மாற்றுத்திறனாளி ஓய்வூதியம்', 'Differently-Abled Pension',
'மாற்றுத்திறனாளிகளுக்கு மாதம் ரூ.1500 ஓய்வூதியம். 40% அல்லது அதற்கு மேல் ஊனம் உள்ளவர்களுக்கு.',
'Monthly pension of Rs.1500 for differently-abled persons with 40% or more disability.',
'state', 'Department for Welfare of Differently Abled Persons', 'https://www.tn.gov.in/dwd', 1),

('tn-fishermen-insurance', 'மீனவர் காப்பீட்டுத் திட்டம்', 'Fishermen Insurance Scheme',
'மீனவர்களுக்கான விபத்து காப்பீடு மற்றும் நிவாரண உதவி. கடலில் உயிரிழப்புக்கு ரூ.5 லட்சம் இழப்பீடு.',
'Accident insurance and relief for fishermen. Rs.5 lakh compensation for loss of life at sea.',
'state', 'Fisheries Department', 'https://www.fisheries.tn.gov.in', 1),

('tn-handloom-workers', 'கைத்தறி நெசவாளர் நலத்திட்டம்', 'Handloom Workers Welfare Scheme',
'கைத்தறி நெசவாளர்களுக்கு நிதி உதவி, இலவச வீடு, கல்வி உதவி மற்றும் ஓய்வூதியம்.',
'Financial assistance, free housing, educational support, and pension for handloom weavers.',
'state', 'Handlooms and Textiles Department', 'https://www.tnhandlooms.tn.gov.in', 1),

('tn-housing-board', 'தமிழ்நாடு வீட்டு வசதி வாரியம்', 'TN Housing Board',
'குறைந்த வருமான குடும்பங்களுக்கு மானிய விலையில் வீடுகள் வழங்கும் திட்டம்.',
'Scheme providing subsidized housing for low-income families through Tamil Nadu Housing Board.',
'state', 'TN Housing Board', 'https://www.tnhb.tn.gov.in', 1),

('tn-free-electricity', 'விவசாயிகளுக்கு இலவச மின்சாரம்', 'Free Electricity for Farmers',
'விவசாய நிலத்தில் பம்ப் செட் இயக்க இலவச மின்சாரம். அனைத்து விவசாயிகளுக்கும் பொருந்தும்.',
'Free electricity for agricultural pump sets. Applicable to all farmers.',
'state', 'TNEB', 'https://www.tangedco.tn.gov.in', 1);

-- ============================================================================
-- ADDITIONAL CENTRAL GOVERNMENT SCHEMES
-- ============================================================================

INSERT OR REPLACE INTO schemes (id, name_tamil, name_english, description_tamil, description_english, level, department, application_url, is_active) VALUES
('cg-ujjwala', 'உஜ்வாலா யோஜனா', 'Pradhan Mantri Ujjwala Yojana',
'ஏழைக் குடும்ப பெண்களுக்கு இலவச LPG இணைப்பு. சமையல் எரிவாயு மானியம் வழங்கப்படும்.',
'Free LPG connection for women from poor families. Cooking gas subsidy provided.',
'central', 'Ministry of Petroleum', 'https://pmuy.gov.in', 1),

('cg-swachh-bharat', 'ஸ்வச் பாரத்', 'Swachh Bharat Mission',
'கிராமப்புற மற்றும் நகர்ப்புறங்களில் கழிப்பறை கட்ட ரூ.12,000 நிதி உதவி. தூய்மை இந்தியா இயக்கம்.',
'Rs.12,000 financial assistance for toilet construction in rural and urban areas. Clean India Mission.',
'central', 'Ministry of Jal Shakti', 'https://swachhbharatmission.gov.in', 1),

('cg-digital-india', 'டிஜிட்டல் இந்தியா', 'Digital India',
'கிராமப்புற இணைய இணைப்பு, டிஜிட்டல் கல்வி, இ-ஆளுமை மற்றும் தொழில்நுட்ப வளர்ச்சிக்கான மத்திய அரசு திட்டம்.',
'Central government initiative for rural internet connectivity, digital literacy, e-governance, and technology growth.',
'central', 'Ministry of Electronics & IT', 'https://digitalindia.gov.in', 1),

('cg-skill-india', 'ஸ்கில் இந்தியா', 'Skill India Mission',
'இளைஞர்களுக்கு இலவச தொழிற்பயிற்சி. 40+ துறைகளில் சான்றிதழ் படிப்புகள் வழங்கப்படும்.',
'Free skill training for youth. Certificate courses offered in 40+ sectors.',
'central', 'Ministry of Skill Development', 'https://www.skillindia.gov.in', 1),

('cg-vishwakarma', 'பிரதம மந்திரி விஸ்வகர்மா', 'PM Vishwakarma Yojana',
'பாரம்பரிய கைவினைஞர்கள் மற்றும் தொழிலாளர்களுக்கு ரூ.3 லட்சம் வரை கடன் உதவி, தொழிற்பயிற்சி மற்றும் கருவிகள்.',
'Loan up to Rs.3 lakh, skill training, and tools for traditional artisans and craftworkers.',
'central', 'Ministry of MSME', 'https://pmvishwakarma.gov.in', 1),

('cg-sukanya', 'சுகன்யா சம்ரிதி யோஜனா', 'Sukanya Samriddhi Yojana',
'பெண் குழந்தைகளுக்கான சிறப்பு சேமிப்பு திட்டம். உயர் வட்டி விகிதம் மற்றும் வரி சலுகை.',
'Special savings scheme for girl children with higher interest rate and tax benefits.',
'central', 'Ministry of Finance', 'https://www.india.gov.in/sukanya-samriddhi-yojana', 1),

('cg-atal-pension', 'அடல் ஓய்வூதிய யோஜனா', 'Atal Pension Yojana',
'அமைப்புசாரா தொழிலாளர்களுக்கான ஓய்வூதிய திட்டம். 60 வயதுக்குப் பின் மாதம் ரூ.1000 முதல் ரூ.5000 வரை ஓய்வூதியம்.',
'Pension scheme for unorganized sector workers. Monthly pension of Rs.1000 to Rs.5000 after age 60.',
'central', 'Ministry of Finance', 'https://npscra.nsdl.co.in/scheme-details.php', 1),

('cg-svanidhi', 'பிரதம மந்திரி ஸ்வநிதி', 'PM SVANidhi',
'தெருக்கடை வியாபாரிகளுக்கு ரூ.10,000 முதல் ரூ.50,000 வரை கடன். பிணை இல்லை, குறைந்த வட்டி.',
'Loan from Rs.10,000 to Rs.50,000 for street vendors. No collateral, low interest rate.',
'central', 'Ministry of Housing & Urban Affairs', 'https://pmsvanidhi.mohua.gov.in', 1),

('cg-nrlm', 'தேசிய கிராமப்புற வாழ்வாதாரம்', 'National Rural Livelihood Mission',
'கிராமப்புற ஏழை பெண்களை சுய உதவிக்குழுக்கள் மூலம் வாழ்வாதாரம் மேம்படுத்தும் திட்டம். கடன் உதவி மற்றும் பயிற்சி.',
'Scheme to improve livelihoods of rural poor women through Self Help Groups with credit support and training.',
'central', 'Ministry of Rural Development', 'https://nrlm.gov.in', 1),

('cg-jan-dhan', 'ஜன் தன் யோஜனா', 'Pradhan Mantri Jan Dhan Yojana',
'அனைவருக்கும் வங்கி கணக்கு, ரூ.2 லட்சம் விபத்து காப்பீடு, ரூ.30,000 ஆயுள் காப்பீடு மற்றும் ரூ.10,000 ஓவர் டிராஃப்ட்.',
'Bank account for everyone with Rs.2 lakh accident insurance, Rs.30,000 life insurance, and Rs.10,000 overdraft facility.',
'central', 'Ministry of Finance', 'https://pmjdy.gov.in', 1),

('cg-pmgsy', 'பிரதம மந்திரி கிராம சாலை யோஜனா', 'PM Gram Sadak Yojana',
'கிராமப்புறங்களுக்கு அனைத்து பருவ சாலைகள் அமைக்கும் திட்டம். 500 மேற்பட்ட மக்கள் தொகை கொண்ட குடியிருப்புகளை இணைக்கும்.',
'All-weather road connectivity scheme for rural areas, connecting habitations with 500+ population.',
'central', 'Ministry of Rural Development', 'https://pmgsy.nic.in', 1),

('cg-pmfby', 'பிரதம மந்திரி பசல் பீமா யோஜனா', 'PM Fasal Bima Yojana',
'விவசாயிகளுக்கான பயிர் காப்பீடு. இயற்கை பேரிடர்களால் பயிர் சேதத்திற்கு இழப்பீடு. குறைந்த பிரீமியம்.',
'Crop insurance for farmers with compensation for crop damage due to natural disasters at low premiums.',
'central', 'Ministry of Agriculture', 'https://pmfby.gov.in', 1),

('cg-ab-hjp', 'ஆயுஷ்மான் பாரத் ஹெல்த் அக்கவுண்ட்', 'Ayushman Bharat Health Account',
'ஒவ்வொரு குடிமகனுக்கும் தனித்துவமான சுகாதார அடையாள எண் (ABHA). டிஜிட்டல் சுகாதார பதிவுகள்.',
'Unique health identity number (ABHA) for every citizen with digital health records.',
'central', 'Ministry of Health', 'https://abha.abdm.gov.in', 1),

('cg-pm-kaushal', 'பிரதம மந்திரி கௌஷல் விகாஸ் யோஜனா', 'PM Kaushal Vikas Yojana',
'இளைஞர்களுக்கு இலவச குறுகிய கால தொழிற்பயிற்சி மற்றும் சான்றிதழ். பயிற்சிக்கு ஊக்கத்தொகையும் வழங்கப்படும்.',
'Free short-term skill training and certification for youth with stipend during training.',
'central', 'Ministry of Skill Development', 'https://pmkvyofficial.org', 1),

('cg-ladli-behna', 'பிரதம மந்திரி மாதரு வந்தனா யோஜனா', 'PM Matru Vandana Yojana',
'கர்ப்பிணி பெண்களுக்கு ரூ.11,000 நேரடி பண மாற்றம். முதல் குழந்தைக்கு ரூ.5,000, இரண்டாம் பெண் குழந்தைக்கு ரூ.6,000.',
'Direct cash transfer of Rs.11,000 for pregnant women. Rs.5,000 for first child and Rs.6,000 for second girl child.',
'central', 'Ministry of Women & Child Development', 'https://pmmvy.wcd.gov.in', 1);

-- ============================================================================
-- ELIGIBILITY CRITERIA FOR ADDITIONAL SCHEMES
-- ============================================================================

INSERT OR REPLACE INTO scheme_eligibility (scheme_id, criteria_tamil, criteria_english, criteria_type, allowed_values) VALUES
-- Amma Unavagam
('tn-amma-unavagam', 'அனைவரும் பயன்படுத்தலாம்', 'Open to all', 'status', 'all'),

-- Free Laptop
('tn-free-laptop', 'அரசு பள்ளி 11 அல்லது 12ம் வகுப்பு மாணவர்', 'Government school student in Class 11 or 12', 'education', 'class_11_12'),
('tn-free-laptop', '75% மேல் வருகைப்பதிவு', 'Attendance above 75%', 'attendance', '75'),

-- Differently-Abled Pension
('tn-differently-abled-pension', '40% அல்லது அதற்கு மேல் ஊனம்', '40% or more disability', 'disability', '40'),
('tn-differently-abled-pension', 'ஆண்டு வருமானம் ரூ.72,000 க்குள்', 'Annual income below Rs.72,000', 'income', '72000'),

-- Fishermen Insurance
('tn-fishermen-insurance', 'பதிவு செய்யப்பட்ட மீனவர்', 'Registered fisherman', 'occupation', 'fisherman'),
('tn-fishermen-insurance', '18 முதல் 65 வயது வரை', 'Age between 18 and 65', 'age', '18-65'),

-- Handloom Workers
('tn-handloom-workers', 'பதிவு செய்யப்பட்ட கைத்தறி நெசவாளர்', 'Registered handloom weaver', 'occupation', 'handloom_weaver'),

-- Free Electricity
('tn-free-electricity', 'விவசாய நிலம் வைத்திருத்தல்', 'Must own agricultural land', 'property', 'agricultural_land'),
('tn-free-electricity', 'விவசாய பம்ப் செட் இணைப்பு', 'Agricultural pump set connection', 'document', 'pump_set_connection'),

-- Ujjwala
('cg-ujjwala', 'BPL குடும்பத்தைச் சேர்ந்த பெண்', 'Woman from BPL family', 'status', 'bpl_woman'),
('cg-ujjwala', 'வேறு LPG இணைப்பு இல்லாதவர்', 'No existing LPG connection', 'document', 'no_lpg'),

-- Swachh Bharat
('cg-swachh-bharat', 'வீட்டில் கழிப்பறை இல்லாத குடும்பம்', 'Household without toilet', 'status', 'no_toilet'),

-- Sukanya Samriddhi
('cg-sukanya', '10 வயதுக்கு கீழ் உள்ள பெண் குழந்தை', 'Girl child below 10 years', 'age', '10'),
('cg-sukanya', 'ஒரு குடும்பத்தில் அதிகபட்சம் 2 கணக்குகள்', 'Maximum 2 accounts per family', 'status', 'max_2'),

-- Atal Pension
('cg-atal-pension', '18 முதல் 40 வயது வரை', 'Age between 18 and 40', 'age', '18-40'),
('cg-atal-pension', 'சேமிப்பு வங்கி கணக்கு இருத்தல்', 'Must have savings bank account', 'document', 'bank_account'),

-- SVANidhi
('cg-svanidhi', 'தெருக்கடை வியாபாரி அடையாள அட்டை', 'Street vendor identity certificate', 'document', 'vendor_certificate'),
('cg-svanidhi', 'நகர்ப்புற உள்ளாட்சி பதிவு', 'Urban local body registration', 'document', 'ulb_registration'),

-- Jan Dhan
('cg-jan-dhan', '10 வயதுக்கு மேற்பட்ட இந்திய குடிமகன்', 'Indian citizen above 10 years', 'age', '10'),

-- NRLM
('cg-nrlm', 'கிராமப்புற ஏழை பெண்கள்', 'Rural poor women', 'status', 'rural_poor_woman'),

-- PM Matru Vandana
('cg-ladli-behna', 'முதல் மற்றும் இரண்டாம் குழந்தைக்கான கர்ப்பிணி', 'Pregnant with first or second child', 'status', 'pregnant_first_second'),
('cg-ladli-behna', '19 வயதுக்கு மேற்பட்ட பெண்', 'Woman above 19 years', 'age', '19'),

-- PM Vishwakarma
('cg-vishwakarma', 'பாரம்பரிய கைவினைஞர் அல்லது தொழிலாளர்', 'Traditional artisan or craftworker', 'occupation', 'artisan'),
('cg-vishwakarma', '18 வயதுக்கு மேற்பட்டவர்', 'Above 18 years of age', 'age', '18'),

-- Transgender Welfare
('tn-transgender-welfare', 'திருநங்கை அடையாள அட்டை பெற்றிருத்தல்', 'Must have transgender identity card', 'document', 'transgender_id'),

-- CM Breakfast
('tn-cm-breakfast', 'அரசு பள்ளி 1 முதல் 5ம் வகுப்பு மாணவர்', 'Government school student Class 1 to 5', 'education', 'class_1_5');

-- ============================================================================
-- REQUIRED DOCUMENTS FOR ADDITIONAL SCHEMES
-- ============================================================================

INSERT OR REPLACE INTO scheme_documents (scheme_id, document_tamil, document_english, is_mandatory) VALUES
-- Free Laptop
('tn-free-laptop', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-free-laptop', 'பள்ளி அடையாள அட்டை', 'School ID Card', 1),
('tn-free-laptop', 'வருகைப்பதிவு சான்றிதழ்', 'Attendance Certificate', 1),

-- Differently-Abled Pension
('tn-differently-abled-pension', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-differently-abled-pension', 'மாற்றுத்திறன் சான்றிதழ்', 'Disability Certificate', 1),
('tn-differently-abled-pension', 'வருமான சான்றிதழ்', 'Income Certificate', 1),
('tn-differently-abled-pension', 'வங்கி கணக்கு', 'Bank Account', 1),

-- Fishermen Insurance
('tn-fishermen-insurance', 'மீனவர் அடையாள அட்டை', 'Fisherman Identity Card', 1),
('tn-fishermen-insurance', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-fishermen-insurance', 'குடும்ப அட்டை', 'Ration Card', 0),

-- Handloom Workers
('tn-handloom-workers', 'நெசவாளர் அடையாள அட்டை', 'Weaver Identity Card', 1),
('tn-handloom-workers', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-handloom-workers', 'வங்கி கணக்கு', 'Bank Account', 1),

-- Free Electricity
('tn-free-electricity', 'நில ஆவணங்கள்', 'Land Records', 1),
('tn-free-electricity', 'விவசாய சான்றிதழ்', 'Agriculture Certificate', 1),
('tn-free-electricity', 'ஆதார் அட்டை', 'Aadhaar Card', 1),

-- Transgender Welfare
('tn-transgender-welfare', 'திருநங்கை அடையாள அட்டை', 'Transgender Identity Card', 1),
('tn-transgender-welfare', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-transgender-welfare', 'வங்கி கணக்கு', 'Bank Account', 1),

-- Housing Board
('tn-housing-board', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-housing-board', 'வருமான சான்றிதழ்', 'Income Certificate', 1),
('tn-housing-board', 'குடும்ப அட்டை', 'Ration Card', 1),
('tn-housing-board', 'சொந்த வீடு இல்லா சான்றிதழ்', 'No House Certificate', 1),

-- Ujjwala
('cg-ujjwala', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-ujjwala', 'BPL அட்டை அல்லது குடும்ப அட்டை', 'BPL Card or Ration Card', 1),
('cg-ujjwala', 'வங்கி கணக்கு', 'Bank Account', 1),
('cg-ujjwala', 'புகைப்படம்', 'Passport Size Photo', 1),

-- Sukanya Samriddhi
('cg-sukanya', 'பெண் குழந்தையின் பிறப்பு சான்றிதழ்', 'Girl Child Birth Certificate', 1),
('cg-sukanya', 'பெற்றோர் ஆதார் அட்டை', 'Parent Aadhaar Card', 1),
('cg-sukanya', 'முகவரி ஆதாரம்', 'Address Proof', 1),

-- Atal Pension
('cg-atal-pension', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-atal-pension', 'வங்கி கணக்கு', 'Bank Account', 1),
('cg-atal-pension', 'மொபைல் எண்', 'Mobile Number', 1),

-- SVANidhi
('cg-svanidhi', 'வியாபாரி அடையாள சான்றிதழ்', 'Vendor Identity Certificate', 1),
('cg-svanidhi', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-svanidhi', 'வங்கி கணக்கு', 'Bank Account', 1),

-- Jan Dhan
('cg-jan-dhan', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-jan-dhan', 'புகைப்படம்', 'Passport Size Photo', 1),

-- NRLM
('cg-nrlm', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-nrlm', 'குடும்ப அட்டை', 'Ration Card', 1),
('cg-nrlm', 'வங்கி கணக்கு', 'Bank Account', 1),

-- PM Vishwakarma
('cg-vishwakarma', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-vishwakarma', 'தொழில் சான்றிதழ்', 'Trade Certificate', 1),
('cg-vishwakarma', 'வங்கி கணக்கு', 'Bank Account', 1),
('cg-vishwakarma', 'புகைப்படம்', 'Passport Size Photo', 1),

-- PM Matru Vandana
('cg-ladli-behna', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-ladli-behna', 'வங்கி கணக்கு', 'Bank Account', 1),
('cg-ladli-behna', 'MCP அட்டை (தாய் மற்றும் குழந்தை பாதுகாப்பு அட்டை)', 'MCP Card (Mother and Child Protection Card)', 1),

-- PM Kaushal Vikas
('cg-pm-kaushal', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-pm-kaushal', 'வங்கி கணக்கு', 'Bank Account', 1),
('cg-pm-kaushal', 'கல்வி சான்றிதழ்', 'Education Certificate', 0);
