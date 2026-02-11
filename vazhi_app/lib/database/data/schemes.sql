-- Government Schemes Data
-- Tamil Nadu and Central Government welfare schemes

-- Clear existing data
DELETE FROM schemes;
DELETE FROM scheme_eligibility;
DELETE FROM scheme_documents;

-- Tamil Nadu State Schemes
INSERT OR REPLACE INTO schemes (id, name_tamil, name_english, description_tamil, description_english, level, department, application_url, is_active) VALUES
('tn-cmchis', 'முதலமைச்சர் மருத்துவ காப்பீட்டுத் திட்டம்', 'CM Comprehensive Health Insurance Scheme',
'தமிழ்நாடு அரசின் இலவச மருத்துவ காப்பீட்டுத் திட்டம். குடும்பத்திற்கு ரூ.5 லட்சம் வரை இலவச சிகிச்சை.',
'Free health insurance scheme by Tamil Nadu Government. Up to Rs.5 lakh free treatment per family.',
'state', 'Health Department', 'https://www.cmchistn.com', 1),

('tn-kalaignar-magalir', 'கலைஞர் மகளிர் உரிமைத் தொகை திட்டம்', 'Kalaignar Magalir Urimai Thogai Scheme',
'பெண்களுக்கு மாதம் ரூ.1000 நேரடி பண மாற்றம். 21 வயதுக்கு மேற்பட்ட அனைத்து பெண்களுக்கும்.',
'Direct cash transfer of Rs.1000 per month to women. For all women above 21 years.',
'state', 'Social Welfare Department', 'https://www.tnsocialwelfare.tn.gov.in', 1),

('tn-free-bus', 'இலவச பேருந்து பயணம்', 'Free Bus Travel for Women',
'பெண்களுக்கு அரசு பேருந்துகளில் இலவச பயணம். நகர மற்றும் கிராமப்புற பேருந்துகளில் பொருந்தும்.',
'Free bus travel for women in government buses. Applicable on city and rural buses.',
'state', 'Transport Department', 'https://www.tnstc.in', 1),

('tn-free-education', 'இலவசக் கல்வி', 'Free Education Scheme',
'அரசு பள்ளிகளில் இலவசக் கல்வி. புத்தகங்கள், சீருடை, மதிய உணவு இலவசம்.',
'Free education in government schools. Free books, uniforms, and mid-day meals.',
'state', 'School Education Department', 'https://www.tnschools.gov.in', 1),

('tn-marriage-assistance', 'திருமண உதவித் தொகை', 'Marriage Assistance Scheme',
'ஏழைக் குடும்ப பெண்களுக்கு திருமண உதவித் தொகை ரூ.50,000. தங்க நகை 8 கிராம்.',
'Marriage assistance of Rs.50,000 for women from poor families. 8 grams gold ornament.',
'state', 'Social Welfare Department', 'https://www.tnsocialwelfare.tn.gov.in', 1),

('tn-old-age-pension', 'முதியோர் ஓய்வூதியம்', 'Old Age Pension Scheme',
'60 வயதுக்கு மேற்பட்ட முதியவர்களுக்கு மாதம் ரூ.1000 ஓய்வூதியம்.',
'Monthly pension of Rs.1000 for senior citizens above 60 years.',
'state', 'Social Welfare Department', 'https://www.tnsocialwelfare.tn.gov.in', 1),

('tn-farmer-insurance', 'விவசாயிகள் காப்பீடு', 'Farmer Insurance Scheme',
'விவசாயிகளுக்கான பயிர் காப்பீடு மற்றும் விபத்து காப்பீடு திட்டம்.',
'Crop insurance and accident insurance scheme for farmers.',
'state', 'Agriculture Department', 'https://www.tnagri.org', 1);

-- Central Government Schemes
INSERT OR REPLACE INTO schemes (id, name_tamil, name_english, description_tamil, description_english, level, department, application_url, is_active) VALUES
('cg-pmjay', 'ஆயுஷ்மான் பாரத்', 'Ayushman Bharat - PMJAY',
'மத்திய அரசின் ஆரோக்கிய காப்பீட்டுத் திட்டம். குடும்பத்திற்கு ரூ.5 லட்சம் வரை இலவச சிகிச்சை.',
'Central government health insurance scheme. Up to Rs.5 lakh free treatment per family.',
'central', 'Ministry of Health', 'https://pmjay.gov.in', 1),

('cg-pmkisan', 'பிரதம மந்திரி கிசான் சம்மான் நிதி', 'PM Kisan Samman Nidhi',
'விவசாயிகளுக்கு ஆண்டுக்கு ரூ.6000 நேரடி பண மாற்றம். மூன்று தவணைகளில் வழங்கப்படும்.',
'Direct cash transfer of Rs.6000 per year to farmers. Disbursed in three installments.',
'central', 'Ministry of Agriculture', 'https://pmkisan.gov.in', 1),

('cg-pmsby', 'பிரதம மந்திரி சுரக்ஷா பீமா யோஜனா', 'PM Suraksha Bima Yojana',
'ஆண்டுக்கு ரூ.20 பிரீமியத்தில் ரூ.2 லட்சம் விபத்து காப்பீடு.',
'Accident insurance of Rs.2 lakh with annual premium of just Rs.20.',
'central', 'Ministry of Finance', 'https://financialservices.gov.in', 1),

('cg-pmjjby', 'பிரதம மந்திரி ஜீவன் ஜோதி பீமா யோஜனா', 'PM Jeevan Jyoti Bima Yojana',
'ஆண்டுக்கு ரூ.436 பிரீமியத்தில் ரூ.2 லட்சம் ஆயுள் காப்பீடு.',
'Life insurance of Rs.2 lakh with annual premium of Rs.436.',
'central', 'Ministry of Finance', 'https://financialservices.gov.in', 1),

('cg-pmay', 'பிரதம மந்திரி ஆவாஸ் யோஜனா', 'PM Awas Yojana',
'ஏழைக் குடும்பங்களுக்கு வீடு கட்ட நிதி உதவி. நகர மற்றும் கிராமப்புற திட்டங்கள்.',
'Financial assistance for housing to poor families. Urban and rural schemes available.',
'central', 'Ministry of Housing', 'https://pmaymis.gov.in', 1),

('cg-mudra', 'முத்ரா கடன்', 'MUDRA Loan Scheme',
'சிறு தொழில் தொடங்க ரூ.50,000 முதல் ரூ.10 லட்சம் வரை கடன். பிணை இல்லை.',
'Loans from Rs.50,000 to Rs.10 lakh for starting small business. No collateral required.',
'central', 'Ministry of Finance', 'https://www.mudra.org.in', 1);

-- Eligibility criteria
INSERT OR REPLACE INTO scheme_eligibility (scheme_id, criteria_tamil, criteria_english, criteria_type, allowed_values) VALUES
('tn-cmchis', 'அரசு குடும்ப அட்டை வைத்திருத்தல்', 'Must have family ration card', 'document', 'ration_card'),
('tn-cmchis', 'ஆண்டு வருமானம் ரூ.72,000 க்குள்', 'Annual income below Rs.72,000', 'income', '72000'),
('tn-kalaignar-magalir', '21 வயதுக்கு மேற்பட்ட பெண்', 'Woman above 21 years', 'age', '21'),
('tn-kalaignar-magalir', 'குடும்ப தலைவி அல்லது கணவன் இல்லாத பெண்', 'Head of family or unmarried/widowed woman', 'status', 'eligible_woman'),
('tn-old-age-pension', '60 வயதுக்கு மேற்பட்டவர்', 'Above 60 years of age', 'age', '60'),
('tn-old-age-pension', 'ஆண்டு வருமானம் ரூ.24,000 க்குள்', 'Annual income below Rs.24,000', 'income', '24000'),
('cg-pmjay', 'SECC 2011 பட்டியலில் இருத்தல்', 'Must be in SECC 2011 list', 'document', 'secc_list'),
('cg-pmkisan', 'விவசாய நிலம் வைத்திருத்தல்', 'Must own agricultural land', 'property', 'agricultural_land'),
('cg-pmkisan', '2 ஹெக்டேர் வரை நிலம்', 'Land up to 2 hectares', 'land_size', '2_hectare');

-- Required documents
INSERT OR REPLACE INTO scheme_documents (scheme_id, document_tamil, document_english, is_mandatory) VALUES
('tn-cmchis', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-cmchis', 'குடும்ப அட்டை', 'Ration Card', 1),
('tn-cmchis', 'வருமான சான்றிதழ்', 'Income Certificate', 1),
('tn-kalaignar-magalir', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-kalaignar-magalir', 'வங்கி கணக்கு', 'Bank Account', 1),
('tn-kalaignar-magalir', 'குடும்ப அட்டை', 'Ration Card', 1),
('tn-old-age-pension', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('tn-old-age-pension', 'வயது சான்றிதழ்', 'Age Proof', 1),
('tn-old-age-pension', 'வருமான சான்றிதழ்', 'Income Certificate', 1),
('cg-pmjay', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-pmjay', 'குடும்ப அட்டை', 'Ration Card', 1),
('cg-pmkisan', 'ஆதார் அட்டை', 'Aadhaar Card', 1),
('cg-pmkisan', 'நில ஆவணங்கள்', 'Land Records', 1),
('cg-pmkisan', 'வங்கி கணக்கு', 'Bank Account', 1);
