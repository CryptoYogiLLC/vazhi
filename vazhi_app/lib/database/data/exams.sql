-- Exams Data
-- Major competitive and entrance exams relevant to Tamil Nadu students

-- Clear existing data
DELETE FROM exams;

-- ============================================================================
-- MEDICAL ENTRANCE EXAMS
-- ============================================================================

INSERT OR REPLACE INTO exams (id, name_tamil, name_english, conducting_body, level, eligibility_tamil, eligibility_english, exam_pattern, syllabus_url, official_site, application_start, application_end, exam_date, result_date) VALUES

('exam-neet-ug', 'நீட் UG', 'NEET UG',
'NTA (National Testing Agency)', 'national',
'12-ஆம் வகுப்பு இயற்பியல், வேதியியல், உயிரியல் படித்தவர்கள். குறைந்தபட்ச வயது 17. 50% மதிப்பெண் (பொது), 40% (OBC/SC/ST).',
'Class 12 pass with Physics, Chemistry, Biology. Minimum age 17. 50% marks (General), 40% (OBC/SC/ST).',
'200 MCQs (Physics 50, Chemistry 50, Biology 100). 720 marks. 3 hours 20 minutes. Negative marking (-1).',
'https://neet.nta.nic.in/information/syllabus',
'https://neet.nta.nic.in',
'February 2026', 'March 2026', 'May 2026', 'June 2026'),

('exam-neet-pg', 'நீட் PG', 'NEET PG',
'NBEMS (National Board of Examinations)', 'national',
'MBBS பட்டம் + 1 வருட கட்டாய கிராம சேவை (internship) முடித்தவர்கள்.',
'MBBS degree holders who have completed 1 year mandatory internship.',
'200 MCQs. Computer Based Test. 3 hours 30 minutes. All subjects of MBBS curriculum.',
'https://natboard.edu.in',
'https://natboard.edu.in',
'July 2026', 'August 2026', 'September 2026', 'October 2026'),

('exam-neet-ss', 'நீட் SS', 'NEET SS (Super Specialty)',
'NBEMS (National Board of Examinations)', 'national',
'MD/MS பட்டம் பெற்றவர்கள். சம்பந்தப்பட்ட சிறப்பு துறையில் பட்டம் பெற்றிருக்க வேண்டும்.',
'MD/MS degree holders. Must have degree in relevant specialty.',
'120 MCQs. Computer Based Test. 2 hours. Specialty-specific questions.',
'https://natboard.edu.in',
'https://natboard.edu.in',
'July 2026', 'August 2026', 'November 2026', 'December 2026');

-- ============================================================================
-- ENGINEERING ENTRANCE EXAMS
-- ============================================================================

INSERT OR REPLACE INTO exams (id, name_tamil, name_english, conducting_body, level, eligibility_tamil, eligibility_english, exam_pattern, syllabus_url, official_site, application_start, application_end, exam_date, result_date) VALUES

('exam-jee-main', 'ஜே.இ.இ. மெயின்', 'JEE Main',
'NTA (National Testing Agency)', 'national',
'12-ஆம் வகுப்பு இயற்பியல், வேதியியல், கணிதம் படித்தவர்கள். 75% மதிப்பெண் (பொது) அல்லது முதல் 20 சதவீதம்.',
'Class 12 pass with Physics, Chemistry, Mathematics. 75% marks (General) or top 20 percentile.',
'90 MCQs (Physics 30, Chemistry 30, Maths 30). 300 marks. 3 hours. Negative marking (-1). Jan & April sessions.',
'https://jeemain.nta.nic.in',
'https://jeemain.nta.nic.in',
'November 2025', 'December 2025', 'January 2026 / April 2026', 'February 2026 / May 2026'),

('exam-jee-advanced', 'ஜே.இ.இ. அட்வான்ஸ்டு', 'JEE Advanced',
'IIT (Rotating)', 'national',
'JEE Main முதல் 2,50,000 பேரில் தகுதி பெற்றவர்கள். 12-ஆம் வகுப்பில் 75% மதிப்பெண். வயது 25 க்கு கீழ்.',
'Top 2,50,000 qualifiers of JEE Main. 75% in Class 12. Age below 25 years.',
'2 Papers (3 hours each). Physics, Chemistry, Maths. MCQ + Numerical. Total 396 marks per paper.',
'https://jeeadv.ac.in',
'https://jeeadv.ac.in',
'April 2026', 'May 2026', 'June 2026', 'June 2026'),

('exam-tnea', 'தமிழ்நாடு பொறியியல் சேர்க்கை (TNEA)', 'TNEA (Tamil Nadu Engineering Admissions)',
'Anna University', 'state',
'12-ஆம் வகுப்பு இயற்பியல், வேதியியல், கணிதம் படித்த தமிழ்நாடு மாணவர்கள். குறைந்தபட்சம் 45% (பொது), 40% (இடஒதுக்கீடு).',
'Tamil Nadu students with Class 12 Physics, Chemistry, Mathematics. Minimum 45% (General), 40% (Reserved).',
'தேர்வு இல்லை - 12-ஆம் வகுப்பு மதிப்பெண் அடிப்படையில் counselling. Cutoff = Maths + Physics + Chemistry marks.',
'https://www.annauniv.edu',
'https://www.tneaonline.org',
'May 2026', 'June 2026', 'தேர்வு இல்லை (Counselling July-August)', 'July 2026');

-- ============================================================================
-- GOVERNMENT JOB EXAMS
-- ============================================================================

INSERT OR REPLACE INTO exams (id, name_tamil, name_english, conducting_body, level, eligibility_tamil, eligibility_english, exam_pattern, syllabus_url, official_site, application_start, application_end, exam_date, result_date) VALUES

('exam-tnpsc-group1', 'TNPSC குரூப் 1', 'TNPSC Group 1 (CCSE-I)',
'TNPSC (Tamil Nadu Public Service Commission)', 'state',
'ஏதேனும் ஒரு பட்டப்படிப்பு. வயது 21-37 (பொது), SC/ST/MBC/BC-க்கு இளவயது தளர்வு உண்டு.',
'Any degree from recognized university. Age 21-37 (General), age relaxation for SC/ST/MBC/BC.',
'Prelims: 200 MCQs (General Studies) 3 hours. Mains: 3 Papers (Tamil, GS, Aptitude) descriptive. Interview.',
'https://www.tnpsc.gov.in',
'https://www.tnpsc.gov.in',
'January 2026', 'February 2026', 'Prelims: May 2026, Mains: September 2026', 'December 2026'),

('exam-tnpsc-group2', 'TNPSC குரூப் 2', 'TNPSC Group 2 (CCSE-II)',
'TNPSC (Tamil Nadu Public Service Commission)', 'state',
'ஏதேனும் ஒரு பட்டப்படிப்பு. வயது 21-37 (பொது). இடஒதுக்கீடு பிரிவினருக்கு வயது தளர்வு.',
'Any degree from recognized university. Age 21-37 (General). Age relaxation for reserved categories.',
'Prelims: 200 MCQs (GS + Aptitude) 3 hours. Mains: Descriptive (Tamil + English + GS). Interview for select posts.',
'https://www.tnpsc.gov.in',
'https://www.tnpsc.gov.in',
'March 2026', 'April 2026', 'Prelims: July 2026', 'October 2026'),

('exam-tnpsc-group2a', 'TNPSC குரூப் 2A', 'TNPSC Group 2A',
'TNPSC (Tamil Nadu Public Service Commission)', 'state',
'ஏதேனும் ஒரு பட்டப்படிப்பு. வயது 18-32 (பொது). இடஒதுக்கீடு பிரிவினருக்கு வயது தளர்வு.',
'Any degree from recognized university. Age 18-32 (General). Age relaxation for reserved categories.',
'Single Paper: 200 MCQs (GS + Aptitude + Tamil). 3 hours. 300 marks. No interview.',
'https://www.tnpsc.gov.in',
'https://www.tnpsc.gov.in',
'April 2026', 'May 2026', 'August 2026', 'November 2026'),

('exam-tnpsc-group4', 'TNPSC குரூப் 4', 'TNPSC Group 4 (CCSE-IV)',
'TNPSC (Tamil Nadu Public Service Commission)', 'state',
'SSLC (10-ஆம் வகுப்பு) தேர்ச்சி. வயது 18-30 (பொது). இடஒதுக்கீடு பிரிவினருக்கு வயது தளர்வு.',
'SSLC (Class 10) pass. Age 18-30 (General). Age relaxation for reserved categories.',
'Single Paper: 200 MCQs (GS + Tamil + Maths + Aptitude). 3 hours. 300 marks. No interview.',
'https://www.tnpsc.gov.in',
'https://www.tnpsc.gov.in',
'February 2026', 'March 2026', 'June 2026', 'August 2026'),

('exam-upsc-cse', 'UPSC சிவில் சர்வீசஸ்', 'UPSC Civil Services Examination (CSE)',
'UPSC (Union Public Service Commission)', 'national',
'ஏதேனும் ஒரு பட்டப்படிப்பு. வயது 21-32 (பொது). OBC-க்கு 35, SC/ST-க்கு 37 வரை. அதிகபட்சம் 6 முயற்சிகள் (பொது).',
'Any degree from recognized university. Age 21-32 (General). Up to 35 for OBC, 37 for SC/ST. Max 6 attempts (General).',
'Prelims: 2 Papers (GS + CSAT) MCQ. Mains: 9 Papers (Essay, GS I-IV, Optional I-II, Tamil/English). Interview.',
'https://www.upsc.gov.in',
'https://www.upsc.gov.in',
'February 2026', 'March 2026', 'Prelims: June 2026, Mains: September 2026', 'March 2027'),

('exam-ssc-cgl', 'SSC CGL', 'SSC CGL (Combined Graduate Level)',
'SSC (Staff Selection Commission)', 'national',
'ஏதேனும் ஒரு பட்டப்படிப்பு. வயது 18-32 (பதவியைப் பொறுத்து மாறுபடும்).',
'Any degree from recognized university. Age 18-32 (varies by post).',
'Tier I: 100 MCQs (GK, Reasoning, Quant, English) 1 hour. Tier II: Computer Based (Maths, English, GK). Tier III: Descriptive.',
'https://ssc.nic.in',
'https://ssc.nic.in',
'April 2026', 'May 2026', 'July 2026', 'December 2026'),

('exam-rrb-ntpc', 'RRB NTPC', 'RRB NTPC (Non-Technical Popular Categories)',
'RRB (Railway Recruitment Board)', 'national',
'12-ஆம் வகுப்பு (சில பதவிகளுக்கு பட்டம்). வயது 18-33 (பதவியைப் பொறுத்து மாறுபடும்).',
'Class 12 (Degree for some posts). Age 18-33 (varies by post).',
'CBT 1: 100 MCQs (GK, Maths, Reasoning) 90 min. CBT 2: 120 MCQs 90 min. Typing/CBAT for specific posts.',
'https://www.rrbchennai.gov.in',
'https://www.rrbchennai.gov.in',
'March 2026', 'April 2026', 'June 2026', 'October 2026');

-- ============================================================================
-- LAW ENTRANCE EXAMS
-- ============================================================================

INSERT OR REPLACE INTO exams (id, name_tamil, name_english, conducting_body, level, eligibility_tamil, eligibility_english, exam_pattern, syllabus_url, official_site, application_start, application_end, exam_date, result_date) VALUES

('exam-clat', 'CLAT', 'CLAT (Common Law Admission Test)',
'NLU Consortium', 'national',
'UG: 12-ஆம் வகுப்பு 45% மதிப்பெண் (பொது), 40% (SC/ST). PG: LLB பட்டம் 50% (பொது).',
'UG: Class 12 with 45% (General), 40% (SC/ST). PG: LLB degree with 50% (General).',
'UG: 150 MCQs (English, GK, Legal, Logical, Quant) 2 hours. PG: 120 MCQs 2 hours. No negative marking.',
'https://consortiumofnlus.ac.in',
'https://consortiumofnlus.ac.in',
'August 2026', 'October 2026', 'December 2026', 'December 2026'),

('exam-ailet', 'AILET', 'AILET (All India Law Entrance Test)',
'NLU Delhi', 'national',
'12-ஆம் வகுப்பு 50% மதிப்பெண் (பொது), 45% (SC/ST). 20 வயதுக்கு கீழ் (பொது).',
'Class 12 with 50% marks (General), 45% (SC/ST). Below 20 years (General).',
'150 MCQs (English, GK, Legal Aptitude, Reasoning, Maths) 1.5 hours. Negative marking (-0.25).',
'https://nludelhi.ac.in',
'https://nludelhi.ac.in',
'September 2026', 'November 2026', 'December 2026', 'January 2027');

-- ============================================================================
-- MBA ENTRANCE EXAMS
-- ============================================================================

INSERT OR REPLACE INTO exams (id, name_tamil, name_english, conducting_body, level, eligibility_tamil, eligibility_english, exam_pattern, syllabus_url, official_site, application_start, application_end, exam_date, result_date) VALUES

('exam-cat', 'CAT', 'CAT (Common Admission Test)',
'IIMs (Rotating)', 'national',
'ஏதேனும் ஒரு பட்டப்படிப்பு 50% மதிப்பெண் (பொது), 45% (SC/ST/PwD).',
'Any degree with 50% marks (General), 45% (SC/ST/PwD).',
'66 MCQs + TITA (VARC 24, DILR 20, QA 22). 2 hours. Negative marking (-1 for MCQ). 198 marks.',
'https://iimcat.ac.in',
'https://iimcat.ac.in',
'August 2026', 'September 2026', 'November 2026', 'January 2027'),

('exam-tancet', 'TANCET', 'TANCET (Tamil Nadu Common Entrance Test)',
'Anna University', 'state',
'MBA: பட்டப்படிப்பு 50% (பொது), 45% (இடஒதுக்கீடு). MCA: BCA/BSc 50%. ME/MTech: BE/BTech 50%.',
'MBA: Degree with 50% (General), 45% (Reserved). MCA: BCA/BSc with 50%. ME/MTech: BE/BTech with 50%.',
'MBA: 100 MCQs (Quant, English, Business, Data) 2 hours. MCA: 100 MCQs (Maths, Analytical, CS) 2 hours.',
'https://www.annauniv.edu',
'https://www.tancet.annauniv.edu',
'January 2026', 'February 2026', 'March 2026', 'April 2026');

-- ============================================================================
-- TEACHING EXAMS
-- ============================================================================

INSERT OR REPLACE INTO exams (id, name_tamil, name_english, conducting_body, level, eligibility_tamil, eligibility_english, exam_pattern, syllabus_url, official_site, application_start, application_end, exam_date, result_date) VALUES

('exam-tntet', 'TN-TET', 'TNTET (Tamil Nadu Teacher Eligibility Test)',
'TRB (Teachers Recruitment Board, TN)', 'state',
'Paper I: D.Ed / D.El.Ed முடித்தவர்கள் (வகுப்பு 1-5). Paper II: B.Ed முடித்தவர்கள் (வகுப்பு 6-8).',
'Paper I: D.Ed / D.El.Ed for Classes 1-5. Paper II: B.Ed for Classes 6-8.',
'Paper I: 150 MCQs (Child Dev, Tamil, English, Maths, EVS) 3 hours. Paper II: 150 MCQs (Child Dev, Language, Subject, Maths/Science or Social) 3 hours.',
'https://trb.tn.gov.in',
'https://trb.tn.gov.in',
'March 2026', 'April 2026', 'June 2026', 'August 2026'),

('exam-ctet', 'CTET', 'CTET (Central Teacher Eligibility Test)',
'CBSE', 'national',
'Paper I: D.Ed / D.El.Ed / 4 வருட B.El.Ed (வகுப்பு 1-5). Paper II: B.Ed அல்லது சமானம் (வகுப்பு 6-8).',
'Paper I: D.Ed / D.El.Ed / 4-year B.El.Ed for Classes 1-5. Paper II: B.Ed or equivalent for Classes 6-8.',
'Paper I: 150 MCQs (Child Dev, Language I & II, Maths, EVS) 2.5 hours. Paper II: 150 MCQs (Child Dev, Language I & II, Subject) 2.5 hours.',
'https://ctet.nic.in',
'https://ctet.nic.in',
'October 2026', 'November 2026', 'December 2026', 'February 2027');

-- ============================================================================
-- BANKING EXAMS
-- ============================================================================

INSERT OR REPLACE INTO exams (id, name_tamil, name_english, conducting_body, level, eligibility_tamil, eligibility_english, exam_pattern, syllabus_url, official_site, application_start, application_end, exam_date, result_date) VALUES

('exam-ibps-po', 'IBPS PO', 'IBPS PO (Probationary Officer)',
'IBPS (Institute of Banking Personnel Selection)', 'national',
'ஏதேனும் ஒரு பட்டப்படிப்பு. வயது 20-30 (பொது). கணினி அறிவு அவசியம்.',
'Any degree from recognized university. Age 20-30 (General). Computer literacy required.',
'Prelims: 100 MCQs (English, Quant, Reasoning) 1 hour. Mains: 155 MCQs + Descriptive (English) 3 hours + 30 min. Interview.',
'https://www.ibps.in',
'https://www.ibps.in',
'August 2026', 'September 2026', 'Prelims: October 2026, Mains: November 2026', 'January 2027'),

('exam-sbi-po', 'SBI PO', 'SBI PO (Probationary Officer)',
'SBI (State Bank of India)', 'national',
'ஏதேனும் ஒரு பட்டப்படிப்பு. வயது 21-30 (பொது). OBC-க்கு 33, SC/ST-க்கு 35 வரை.',
'Any degree from recognized university. Age 21-30 (General). Up to 33 for OBC, 35 for SC/ST.',
'Prelims: 100 MCQs (English 30, Quant 35, Reasoning 35) 1 hour. Mains: 155 MCQs + Descriptive 3.5 hours. Group Exercise + Interview.',
'https://www.sbi.co.in/careers',
'https://www.sbi.co.in/careers',
'March 2026', 'April 2026', 'Prelims: June 2026, Mains: July 2026', 'September 2026');

-- ============================================================================
-- DEFENCE EXAMS
-- ============================================================================

INSERT OR REPLACE INTO exams (id, name_tamil, name_english, conducting_body, level, eligibility_tamil, eligibility_english, exam_pattern, syllabus_url, official_site, application_start, application_end, exam_date, result_date) VALUES

('exam-nda', 'NDA', 'NDA (National Defence Academy)',
'UPSC', 'national',
'12-ஆம் வகுப்பு தேர்ச்சி (கணிதம் + இயற்பியல் - Navy/Air Force). வயது 16.5-19.5. திருமணமாகாதவர்.',
'Class 12 pass (Maths + Physics for Navy/Air Force). Age 16.5-19.5. Unmarried males only.',
'Paper I: Maths (300 marks) 2.5 hours. Paper II: GAT (600 marks) 2.5 hours. Both MCQ. Negative marking. SSB Interview.',
'https://www.upsc.gov.in',
'https://www.upsc.gov.in',
'January 2026', 'February 2026', 'April 2026', 'June 2026'),

('exam-cds', 'CDS', 'CDS (Combined Defence Services)',
'UPSC', 'national',
'ஏதேனும் ஒரு பட்டப்படிப்பு (IMA, OTA). பொறியியல் பட்டம் (Naval/Air Force). வயது 19-25 (பதவியைப் பொறுத்து).',
'Any degree (IMA, OTA). Engineering degree (Naval/Air Force). Age 19-25 (varies by entry).',
'3 Papers: English (100 marks), GK (100 marks), Elementary Maths (100 marks). Each 2 hours. MCQ. SSB Interview.',
'https://www.upsc.gov.in',
'https://www.upsc.gov.in',
'April 2026', 'May 2026', 'September 2026', 'November 2026');
