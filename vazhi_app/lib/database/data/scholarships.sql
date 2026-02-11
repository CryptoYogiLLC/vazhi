-- Scholarships Data
-- Scholarships available to Tamil Nadu students (State, Central, Private)

-- Clear existing data
DELETE FROM scholarships;

-- ============================================================================
-- TAMIL NADU STATE SCHOLARSHIPS
-- ============================================================================

INSERT OR REPLACE INTO scholarships (id, name_tamil, name_english, provider, department, description_tamil, description_english, amount, education_level, category, income_limit, application_start, application_end, apply_url, is_active) VALUES

-- BC/MBC Scholarships
('tn-bc-scholarship', 'பிற்படுத்தப்பட்டோர் உதவித்தொகை', 'BC Post Matric Scholarship',
'தமிழ்நாடு அரசு', 'பிற்படுத்தப்பட்டோர் நலத்துறை',
'பிற்படுத்தப்பட்ட வகுப்பினருக்கான கல்வி உதவித்தொகை. கல்வி கட்டணம் மற்றும் பராமரிப்பு படி வழங்கப்படும்.',
'Educational scholarship for Backward Class students. Covers tuition fees and maintenance allowance.',
'கல்வி கட்டணம் + ரூ.1,200 பராமரிப்பு படி (ஆண்டு)', 'ug', 'obc_mbc',
'ஆண்டு வருமானம் ரூ.2,00,000 க்கு கீழ்', 'July 2026', 'October 2026',
'https://www.bcmbcmw.tn.gov.in', 1),

('tn-mbc-scholarship', 'மிகவும் பிற்படுத்தப்பட்டோர் உதவித்தொகை', 'MBC Post Matric Scholarship',
'தமிழ்நாடு அரசு', 'மிகவும் பிற்படுத்தப்பட்டோர் நலத்துறை',
'மிகவும் பிற்படுத்தப்பட்ட வகுப்பினருக்கான கல்வி உதவித்தொகை. கல்லூரி கல்வி செலவுகள் வழங்கப்படும்.',
'Educational scholarship for Most Backward Class students. Covers college education expenses.',
'கல்வி கட்டணம் + ரூ.1,500 பராமரிப்பு படி (ஆண்டு)', 'ug', 'obc_mbc',
'ஆண்டு வருமானம் ரூ.2,00,000 க்கு கீழ்', 'July 2026', 'October 2026',
'https://www.bcmbcmw.tn.gov.in', 1),

-- SC/ST Scholarships
('tn-sc-scholarship', 'ஆதிதிராவிடர் மாணவர் உதவித்தொகை', 'SC Post Matric Scholarship',
'தமிழ்நாடு அரசு', 'ஆதிதிராவிடர் நலத்துறை',
'பட்டியலின சாதி மாணவர்களுக்கான முழு கல்வி உதவித்தொகை. கல்வி கட்டணம், புத்தகம், உணவு, தங்குமிடம் உள்ளிட்ட அனைத்து செலவுகளும் வழங்கப்படும்.',
'Full educational scholarship for SC students. Covers tuition, books, food, hostel and all expenses.',
'முழு கல்வி கட்டணம் + ரூ.3,500 பராமரிப்பு படி (மாதம்)', 'all', 'sc_st',
'ஆண்டு வருமானம் ரூ.2,50,000 க்கு கீழ்', 'July 2026', 'October 2026',
'https://www.adwelfare.tn.gov.in', 1),

('tn-st-scholarship', 'பழங்குடியின மாணவர் உதவித்தொகை', 'ST Post Matric Scholarship',
'தமிழ்நாடு அரசு', 'ஆதிதிராவிடர் மற்றும் பழங்குடியினர் நலத்துறை',
'பழங்குடியின மாணவர்களுக்கான முழு கல்வி உதவித்தொகை. பள்ளி முதல் ஆராய்ச்சி வரை அனைத்து நிலைகளுக்கும் பொருந்தும்.',
'Full educational scholarship for ST students. Applicable from school to research level.',
'முழு கல்வி கட்டணம் + ரூ.3,500 பராமரிப்பு படி (மாதம்)', 'all', 'sc_st',
'ஆண்டு வருமானம் ரூ.2,50,000 க்கு கீழ்', 'July 2026', 'October 2026',
'https://www.adwelfare.tn.gov.in', 1),

-- First Graduate
('tn-first-graduate', 'முதல் தலைமுறை பட்டதாரி உதவித்தொகை', 'First Graduate Scholarship',
'தமிழ்நாடு அரசு', 'உயர்கல்வித் துறை',
'குடும்பத்தில் முதல் தலைமுறை பட்டதாரியாக கல்லூரியில் சேரும் மாணவர்களுக்கான உதவித்தொகை.',
'Scholarship for students who are the first in their family to attend college.',
'ரூ.10,000 (ஆண்டு)', 'ug', 'general',
'ஆண்டு வருமானம் ரூ.2,50,000 க்கு கீழ்', 'August 2026', 'November 2026',
'https://www.tn.gov.in/scheme/data_view/7127', 1),

-- Merit Scholarship
('tn-merit-scholarship', 'தமிழ்நாடு அரசு மேன்மை உதவித்தொகை', 'TN Government Merit Scholarship',
'தமிழ்நாடு அரசு', 'உயர்கல்வித் துறை',
'12-ஆம் வகுப்பில் உயர்ந்த மதிப்பெண் பெற்ற மாணவர்களுக்கான மேன்மை உதவித்தொகை.',
'Merit scholarship for students who scored high marks in Class 12 examinations.',
'ரூ.12,000 (ஆண்டு)', 'ug', 'merit',
NULL, 'August 2026', 'October 2026',
'https://www.tn.gov.in/scheme/data_view/7127', 1),

-- Free Education for Girls
('tn-girl-education', 'பெண்கள் இலவச உயர்கல்வி', 'Free Higher Education for Girls',
'தமிழ்நாடு அரசு', 'உயர்கல்வித் துறை',
'அரசு கல்லூரிகளில் பெண் மாணவர்களுக்கு இலவச இளநிலை பட்டப்படிப்பு. கல்வி கட்டணம் முழுவதும் அரசு ஏற்கும்.',
'Free undergraduate education for girl students in government colleges. Full tuition fee waiver by government.',
'முழு கல்வி கட்டணம் இலவசம்', 'ug', 'women',
NULL, 'June 2026', 'September 2026',
'https://www.tn.gov.in', 1),

-- Moovalur Ramamirtham Ammaiyar Scheme
('tn-moovalur', 'மூவலூர் ராமமிர்தம் அம்மையார் திட்டம்', 'Moovalur Ramamirtham Ammaiyar Scheme',
'தமிழ்நாடு அரசு', 'சமூக நலன் மற்றும் பெண்கள் உரிமைத் துறை',
'பள்ளிப்படிப்பை முடித்த பெண்களுக்கு ரூ.1,000 மாதம் உதவித்தொகை. 12-ஆம் வகுப்பு வரை படிக்கும் அனைத்து பெண் மாணவர்களுக்கும் பொருந்தும்.',
'Monthly assistance of Rs.1,000 for girl students continuing education. Applicable for all girl students studying up to Class 12.',
'ரூ.1,000 (மாதம்)', 'school', 'women',
NULL, 'July 2026', 'September 2026',
'https://www.tnsocialwelfare.tn.gov.in', 1),

-- Differently Abled
('tn-differently-abled', 'மாற்றுத்திறனாளிகள் கல்வி உதவித்தொகை', 'Differently Abled Students Scholarship',
'தமிழ்நாடு அரசு', 'மாற்றுத்திறனாளிகள் நலத்துறை',
'மாற்றுத்திறனாளி மாணவர்களுக்கான சிறப்பு கல்வி உதவித்தொகை. அனைத்து கல்வி நிலைகளுக்கும் பொருந்தும்.',
'Special educational scholarship for differently abled students. Applicable for all education levels.',
'ரூ.6,000 - ரூ.12,000 (ஆண்டு)', 'all', 'differently_abled',
NULL, 'July 2026', 'October 2026',
'https://www.welfare.tn.gov.in', 1),

-- EVR Nagammaiyar Memorial Scholarship
('tn-evr-nagammaiyar', 'ஈ.வெ.ரா. நாகம்மையார் நினைவு உதவித்தொகை', 'EVR Nagammaiyar Memorial Scholarship',
'தமிழ்நாடு அரசு', 'பிற்படுத்தப்பட்டோர் நலத்துறை',
'தொழிற்கல்வி படிக்கும் BC/MBC பெண் மாணவர்களுக்கான உதவித்தொகை.',
'Scholarship for BC/MBC girl students pursuing professional courses.',
'ரூ.10,000 (ஆண்டு)', 'professional', 'women',
'ஆண்டு வருமானம் ரூ.2,00,000 க்கு கீழ்', 'August 2026', 'November 2026',
'https://www.bcmbcmw.tn.gov.in', 1);

-- ============================================================================
-- CENTRAL GOVERNMENT SCHOLARSHIPS
-- ============================================================================

INSERT OR REPLACE INTO scholarships (id, name_tamil, name_english, provider, department, description_tamil, description_english, amount, education_level, category, income_limit, application_start, application_end, apply_url, is_active) VALUES

-- Post Matric Scholarship SC
('cg-post-matric-sc', 'மத்திய அரசு பட்டியலின மாணவர் உதவித்தொகை', 'Central Post Matric Scholarship for SC',
'இந்திய அரசு', 'சமூக நீதி அமைச்சகம்',
'பட்டியலின மாணவர்களுக்கான மத்திய அரசு உதவித்தொகை. 11-ஆம் வகுப்பு முதல் ஆராய்ச்சி வரை பொருந்தும். கல்வி கட்டணம் மற்றும் பராமரிப்பு படி.',
'Central government scholarship for SC students. Applicable from Class 11 to research level. Covers tuition and maintenance allowance.',
'கல்வி கட்டணம் + ரூ.1,200 - ரூ.3,000 பராமரிப்பு படி (மாதம்)', 'all', 'sc_st',
'ஆண்டு வருமானம் ரூ.2,50,000 க்கு கீழ்', 'August 2026', 'November 2026',
'https://scholarships.gov.in', 1),

-- Post Matric Scholarship ST
('cg-post-matric-st', 'மத்திய அரசு பழங்குடியின மாணவர் உதவித்தொகை', 'Central Post Matric Scholarship for ST',
'இந்திய அரசு', 'பழங்குடியினர் நலன் அமைச்சகம்',
'பழங்குடியின மாணவர்களுக்கான மத்திய அரசு உதவித்தொகை. கல்வி கட்டணம் மற்றும் மாத பராமரிப்பு படி வழங்கப்படும்.',
'Central government scholarship for ST students. Covers tuition fees and monthly maintenance allowance.',
'கல்வி கட்டணம் + ரூ.1,200 - ரூ.3,000 பராமரிப்பு படி (மாதம்)', 'all', 'sc_st',
'ஆண்டு வருமானம் ரூ.2,50,000 க்கு கீழ்', 'August 2026', 'November 2026',
'https://scholarships.gov.in', 1),

-- Post Matric Scholarship OBC
('cg-post-matric-obc', 'மத்திய அரசு பிற்படுத்தப்பட்டோர் உதவித்தொகை', 'Central Post Matric Scholarship for OBC',
'இந்திய அரசு', 'சமூக நீதி அமைச்சகம்',
'பிற பிற்படுத்தப்பட்ட வகுப்பினருக்கான மத்திய அரசு உதவித்தொகை. தொழிற்கல்வி மற்றும் பட்டப்படிப்புகளுக்கு பொருந்தும்.',
'Central government scholarship for OBC students. Applicable for professional and degree courses.',
'கல்வி கட்டணம் + ரூ.750 - ரூ.1,000 பராமரிப்பு படி (மாதம்)', 'ug', 'obc_mbc',
'ஆண்டு வருமானம் ரூ.1,50,000 க்கு கீழ்', 'August 2026', 'November 2026',
'https://scholarships.gov.in', 1),

-- National Means Merit Scholarship
('cg-nmms', 'தேசிய வழிமுறை மேன்மை உதவித்தொகை', 'National Means-cum-Merit Scholarship (NMMS)',
'இந்திய அரசு', 'கல்வி அமைச்சகம்',
'8-ஆம் வகுப்பு மாணவர்களுக்கான தேர்வு அடிப்படையிலான உதவித்தொகை. 12-ஆம் வகுப்பு வரை ஆண்டுக்கு ரூ.12,000 வழங்கப்படும்.',
'Examination-based scholarship for Class 8 students. Rs.12,000 per year till Class 12.',
'ரூ.12,000 (ஆண்டு)', 'school', 'merit',
'ஆண்டு வருமானம் ரூ.3,50,000 க்கு கீழ்', 'August 2026', 'November 2026',
'https://scholarships.gov.in', 1),

-- INSPIRE
('cg-inspire', 'இன்ஸ்பையர் உதவித்தொகை', 'INSPIRE Scholarship (SHE)',
'இந்திய அரசு', 'அறிவியல் தொழில்நுட்ப துறை (DST)',
'அறிவியல் பாடங்களில் இளநிலை படிப்புக்கான உதவித்தொகை. 12-ஆம் வகுப்பில் முதல் 1% மதிப்பெண் பெற்றவர்களுக்கு.',
'Scholarship for BSc students in natural and basic sciences. For top 1% scorers in Class 12.',
'ரூ.80,000 (ஆண்டு)', 'ug', 'merit',
NULL, 'September 2026', 'December 2026',
'https://online-inspire.gov.in', 1),

-- Pragati (Girls in Tech)
('cg-pragati', 'பிரகதி உதவித்தொகை (தொழில்நுட்ப பெண்கள்)', 'Pragati Scholarship for Girls in Technical Education',
'இந்திய அரசு', 'AICTE',
'தொழில்நுட்ப படிப்புகளில் சேரும் பெண் மாணவர்களுக்கான AICTE உதவித்தொகை. பொறியியல், மருத்துவம் உள்ளிட்ட படிப்புகளுக்கு.',
'AICTE scholarship for girl students in technical education. For engineering, medical and other technical courses.',
'ரூ.50,000 (ஆண்டு)', 'professional', 'women',
'ஆண்டு வருமானம் ரூ.8,00,000 க்கு கீழ்', 'September 2026', 'December 2026',
'https://www.aicte-india.org/schemes/students-development-schemes/Pragati', 1),

-- Minority Scholarship
('cg-minority-merit', 'சிறுபான்மையினர் மேன்மை உதவித்தொகை', 'Merit-cum-Means Scholarship for Minorities',
'இந்திய அரசு', 'சிறுபான்மையினர் நலன் அமைச்சகம்',
'சிறுபான்மை சமூக மாணவர்களுக்கான மேன்மை அடிப்படையிலான உதவித்தொகை. தொழிற்கல்வி மற்றும் தொழில்நுட்ப படிப்புகளுக்கு.',
'Merit-based scholarship for minority community students. For professional and technical courses.',
'முழு கல்வி கட்டணம் + ரூ.10,000 பராமரிப்பு படி (ஆண்டு)', 'professional', 'minority',
'ஆண்டு வருமானம் ரூ.2,50,000 க்கு கீழ்', 'August 2026', 'November 2026',
'https://scholarships.gov.in', 1),

-- Pre Matric Scholarship for Minorities
('cg-minority-prematric', 'சிறுபான்மையினர் முன்-மெட்ரிக் உதவித்தொகை', 'Pre-Matric Scholarship for Minorities',
'இந்திய அரசு', 'சிறுபான்மையினர் நலன் அமைச்சகம்',
'1-ஆம் வகுப்பு முதல் 10-ஆம் வகுப்பு வரை படிக்கும் சிறுபான்மை சமூக மாணவர்களுக்கான உதவித்தொகை.',
'Scholarship for minority students studying from Class 1 to Class 10.',
'ரூ.1,000 - ரூ.10,700 (ஆண்டு)', 'school', 'minority',
'ஆண்டு வருமானம் ரூ.1,00,000 க்கு கீழ்', 'August 2026', 'November 2026',
'https://scholarships.gov.in', 1),

-- PM Scholarship for Wards of Ex-Servicemen
('cg-pm-exservicemen', 'முன்னாள் படைவீரர் குடும்ப உதவித்தொகை', 'PM Scholarship for Wards of Ex-Servicemen',
'இந்திய அரசு', 'முன்னாள் படைவீரர் நலத்துறை',
'முன்னாள் படைவீரர்கள் மற்றும் முன்னாள் கடலோர காவல் படையினர் பிள்ளைகளுக்கான உதவித்தொகை.',
'Scholarship for children of ex-servicemen and ex-coast guard personnel for professional degree courses.',
'ரூ.3,000 (மாதம் - ஆண்), ரூ.3,000 (மாதம் - பெண்)', 'professional', 'general',
NULL, 'October 2026', 'December 2026',
'https://ksb.gov.in', 1);

-- ============================================================================
-- PROFESSIONAL / UGC / CSIR SCHOLARSHIPS
-- ============================================================================

INSERT OR REPLACE INTO scholarships (id, name_tamil, name_english, provider, department, description_tamil, description_english, amount, education_level, category, income_limit, application_start, application_end, apply_url, is_active) VALUES

-- AICTE Saksham
('cg-aicte-saksham', 'சக்ஷம் உதவித்தொகை (AICTE)', 'AICTE Saksham Scholarship for Differently Abled',
'AICTE', 'அகில இந்திய தொழில்நுட்ப கல்வி கவுன்சில்',
'மாற்றுத்திறனாளி மாணவர்களுக்கான AICTE உதவித்தொகை. தொழில்நுட்ப கல்வி படிக்கும் 40% மேல் ஊனமுற்றவர்களுக்கு.',
'AICTE scholarship for differently abled students with 40%+ disability pursuing technical education.',
'ரூ.50,000 (ஆண்டு)', 'professional', 'differently_abled',
'ஆண்டு வருமானம் ரூ.8,00,000 க்கு கீழ்', 'September 2026', 'December 2026',
'https://www.aicte-india.org/schemes/students-development-schemes/Saksham', 1),

-- UGC NET JRF
('cg-ugc-jrf', 'UGC NET ஆராய்ச்சி உதவித்தொகை', 'UGC NET Junior Research Fellowship (JRF)',
'UGC', 'பல்கலைக்கழக மானியக் குழு',
'NET தேர்வில் JRF தகுதி பெற்ற மாணவர்களுக்கான ஆராய்ச்சி உதவித்தொகை. PhD படிப்புக்கு 5 ஆண்டுகள் வரை.',
'Research fellowship for students qualifying NET JRF. Up to 5 years for PhD.',
'ரூ.37,000 (மாதம் - முதல் 2 ஆண்டுகள்), ரூ.42,000 (3-5 ஆண்டுகள்)', 'research', 'merit',
NULL, 'March 2026', 'April 2026',
'https://ugcnet.nta.ac.in', 1),

-- CSIR NET JRF
('cg-csir-jrf', 'CSIR NET ஆராய்ச்சி உதவித்தொகை', 'CSIR NET Junior Research Fellowship (JRF)',
'CSIR', 'அறிவியல் மற்றும் தொழில் ஆராய்ச்சி கவுன்சில்',
'அறிவியல் பாடங்களில் CSIR NET JRF தகுதி பெற்றவர்களுக்கான ஆராய்ச்சி உதவித்தொகை.',
'Research fellowship for CSIR NET JRF qualifiers in science subjects.',
'ரூ.37,000 (மாதம் - முதல் 2 ஆண்டுகள்), ரூ.42,000 (3-5 ஆண்டுகள்)', 'research', 'merit',
NULL, 'March 2026', 'April 2026',
'https://csirnet.nta.ac.in', 1),

-- GATE Scholarship
('cg-gate-scholarship', 'GATE உதவித்தொகை', 'GATE Scholarship for MTech/ME',
'AICTE / MHRD', 'கல்வி அமைச்சகம்',
'GATE தேர்வில் தகுதி பெற்ற MTech/ME மாணவர்களுக்கான மாத உதவித்தொகை.',
'Monthly scholarship for MTech/ME students who qualified GATE examination.',
'ரூ.12,400 (மாதம்)', 'pg', 'merit',
NULL, 'February 2026', 'March 2026',
'https://gate2026.iisc.ac.in', 1),

-- AICTE PG Scholarship
('cg-aicte-pg', 'AICTE முதுகலை உதவித்தொகை', 'AICTE PG Scholarship for GATE/GPAT Qualified',
'AICTE', 'அகில இந்திய தொழில்நுட்ப கல்வி கவுன்சில்',
'GATE/GPAT தகுதி பெற்ற முதுகலை மாணவர்களுக்கான AICTE உதவித்தொகை.',
'AICTE scholarship for GATE/GPAT qualified PG students in AICTE approved institutions.',
'ரூ.12,400 (மாதம்)', 'pg', 'merit',
NULL, 'August 2026', 'October 2026',
'https://www.aicte-india.org', 1);

-- ============================================================================
-- PRIVATE SCHOLARSHIPS
-- ============================================================================

INSERT OR REPLACE INTO scholarships (id, name_tamil, name_english, provider, department, description_tamil, description_english, amount, education_level, category, income_limit, application_start, application_end, apply_url, is_active) VALUES

-- Tata Trust
('pvt-tata-trust', 'டாடா அறக்கட்டளை கல்வி உதவித்தொகை', 'Tata Trusts Education Scholarship',
'டாடா அறக்கட்டளை', 'Tata Trusts',
'மருத்துவம், பொறியியல், சட்டம் உள்ளிட்ட தொழிற்கல்வி படிப்புகளுக்கான டாடா அறக்கட்டளை உதவித்தொகை.',
'Tata Trusts scholarship for professional courses including medicine, engineering, and law.',
'கல்வி கட்டணத்தில் 80% வரை', 'professional', 'need',
'ஆண்டு வருமானம் ரூ.6,00,000 க்கு கீழ்', 'August 2026', 'October 2026',
'https://www.tatatrusts.org', 1),

-- Infosys Foundation
('pvt-infosys', 'இன்ஃபோசிஸ் அறக்கட்டளை உதவித்தொகை', 'Infosys Foundation Scholarship',
'இன்ஃபோசிஸ் அறக்கட்டளை', 'Infosys Foundation',
'பொறியியல் மற்றும் அறிவியல் மாணவர்களுக்கான இன்ஃபோசிஸ் அறக்கட்டளை உதவித்தொகை.',
'Infosys Foundation scholarship for engineering and science students from economically weaker sections.',
'ரூ.1,20,000 (ஆண்டு)', 'ug', 'need',
'ஆண்டு வருமானம் ரூ.3,00,000 க்கு கீழ்', 'July 2026', 'September 2026',
'https://www.infosys.com/infosys-foundation', 1),

-- Reliance Foundation
('pvt-reliance', 'ரிலையன்ஸ் அறக்கட்டளை உதவித்தொகை', 'Reliance Foundation Scholarship',
'ரிலையன்ஸ் அறக்கட்டளை', 'Reliance Foundation',
'இளநிலை படிப்பில் சேரும் தகுதியான மாணவர்களுக்கான ரிலையன்ஸ் அறக்கட்டளை உதவித்தொகை. STEM, மனிதநேயம், சட்டம் படிப்புகளுக்கு.',
'Reliance Foundation scholarship for meritorious students pursuing undergraduate studies in STEM, humanities, and law.',
'ரூ.2,00,000 (ஆண்டு) வரை', 'ug', 'merit',
'ஆண்டு வருமானம் ரூ.15,00,000 க்கு கீழ்', 'June 2026', 'August 2026',
'https://www.reliancefoundation.org/scholarships', 1),

-- Wipro
('pvt-wipro', 'விப்ரோ கல்வி உதவித்தொகை', 'Wipro Education Scholarship',
'விப்ரோ', 'Wipro Foundation',
'பொறியியல் கல்லூரிகளில் முதலாம் ஆண்டு படிக்கும் மாணவர்களுக்கான விப்ரோ உதவித்தொகை.',
'Wipro scholarship for first-year engineering students from low-income families.',
'கல்வி கட்டணம் + ரூ.5,000 பராமரிப்பு படி (மாதம்)', 'professional', 'need',
'ஆண்டு வருமானம் ரூ.5,00,000 க்கு கீழ்', 'July 2026', 'September 2026',
'https://www.wipro.com', 1),

-- TVS
('pvt-tvs', 'TVS கல்வி உதவித்தொகை', 'TVS Srinivasan Trust Scholarship',
'TVS குழுமம்', 'TVS Srinivasan Trust',
'தமிழ்நாட்டு மாணவர்களுக்கான TVS குழும கல்வி உதவித்தொகை. பொறியியல் மற்றும் தொழிற்கல்வி படிப்புகளுக்கு.',
'TVS Group education scholarship for Tamil Nadu students. For engineering and professional courses.',
'ரூ.50,000 (ஆண்டு)', 'professional', 'need',
'ஆண்டு வருமானம் ரூ.4,00,000 க்கு கீழ்', 'August 2026', 'October 2026',
'https://www.tvssrichakra.com/tvs-srinivasan-trust', 1),

-- Medical Students
('pvt-medical-aid', 'மருத்துவ மாணவர் உதவி நிதி', 'Medical Students Aid Fund (Tamil Nadu)',
'தமிழ்நாடு மருத்துவ மாணவர் நல சங்கம்', 'Medical Education Department',
'தமிழ்நாட்டில் MBBS படிக்கும் பொருளாதாரத்தில் பின்தங்கிய மாணவர்களுக்கான உதவி நிதி.',
'Financial aid fund for economically backward students pursuing MBBS in Tamil Nadu.',
'ரூ.1,00,000 (ஆண்டு) வரை', 'professional', 'need',
'ஆண்டு வருமானம் ரூ.3,00,000 க்கு கீழ்', 'September 2026', 'November 2026',
'https://www.tn.gov.in/healthfamilywelfare', 1),

-- Law Students
('pvt-law-scholarship', 'சட்ட மாணவர் உதவித்தொகை', 'Bar Council of India Scholarship for Law Students',
'இந்திய வழக்கறிஞர் சங்கம்', 'Bar Council of India',
'சட்டப் படிப்பு படிக்கும் SC/ST/OBC மாணவர்களுக்கான உதவித்தொகை.',
'Bar Council of India scholarship for SC/ST/OBC students pursuing law courses.',
'ரூ.20,000 (ஆண்டு)', 'professional', 'sc_st',
'ஆண்டு வருமானம் ரூ.5,00,000 க்கு கீழ்', 'August 2026', 'October 2026',
'https://www.barcouncilofindia.org', 1),

-- Arts Students
('pvt-arts-culture', 'கலை மற்றும் பண்பாட்டு உதவித்தொகை', 'CCRT Scholarship for Young Artistes',
'இந்திய அரசு', 'CCRT (Centre for Cultural Resources and Training)',
'இந்திய கலை மற்றும் பண்பாட்டு துறையில் திறமை வாய்ந்த இளம் கலைஞர்களுக்கான உதவித்தொகை.',
'Scholarship for young artistes to pursue advanced training in Indian art and culture.',
'ரூ.6,000 (மாதம்) + ரூ.6,000 புத்தகம் (ஆண்டு)', 'ug', 'merit',
NULL, 'January 2026', 'March 2026',
'https://ccrtindia.gov.in', 1),

-- Engineering Students - AICTE Swanath
('cg-aicte-swanath', 'AICTE ஸ்வநாத் உதவித்தொகை', 'AICTE Swanath Scholarship for Orphans/Wards of Armed Forces',
'AICTE', 'அகில இந்திய தொழில்நுட்ப கல்வி கவுன்சில்',
'அனாதை குழந்தைகள், படைவீரர் குழந்தைகள் மற்றும் கட்டுமான தொழிலாளர் குழந்தைகளுக்கான உதவித்தொகை.',
'AICTE scholarship for orphans, wards of armed forces, and children of construction workers pursuing technical education.',
'ரூ.50,000 (ஆண்டு)', 'professional', 'general',
'ஆண்டு வருமானம் ரூ.8,00,000 க்கு கீழ்', 'September 2026', 'December 2026',
'https://www.aicte-india.org/schemes/students-development-schemes/Swanath%20Scholarship%20Scheme', 1);
