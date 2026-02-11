-- Legal Rights Data
-- Citizen rights information for Tamil Nadu residents
-- Covers fundamental, consumer, women, worker, tenant, RTI, digital, SC/ST, senior, and property rights

-- Clear existing data
DELETE FROM legal_rights;

-- =============================================
-- FUNDAMENTAL RIGHTS (Articles 14-32)
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('சமத்துவ உரிமை', 'Right to Equality',
'சட்டத்தின் முன் அனைவரும் சமம். சாதி, மதம், பால், பிறப்பிடம் அடிப்படையில் பாகுபாடு காட்டுவது குற்றம். அரசு வேலை வாய்ப்பில் சம வாய்ப்பு உறுதி.',
'All are equal before the law. Discrimination on grounds of caste, religion, sex, or place of birth is an offence. Equal opportunity in government employment is guaranteed.',
'Constitution of India', 'Articles 14, 15, 16',
'fundamental',
'1. பாகுபாடு நடந்தால் உடனடியாக புகார் பதிவு செய்யுங்கள்
2. மாவட்ட ஆட்சியர் அலுவலகத்தில் மனு கொடுக்கலாம்
3. தேசிய மனித உரிமை ஆணையத்தில் புகார் அளிக்கலாம் (nhrc.nic.in)
4. உயர்நீதிமன்றத்தில் ரிட் மனு (Writ Petition) தாக்கல் செய்யலாம்
5. இலவச சட்ட உதவி: 15100 (NALSA) என்ற எண்ணில் தொடர்பு கொள்ளுங்கள்',
'1. File a complaint immediately if discrimination occurs
2. Submit petition to District Collector office
3. File complaint with National Human Rights Commission (nhrc.nic.in)
4. File a Writ Petition in the High Court
5. Free legal aid: Contact 15100 (NALSA)'),

('பேச்சு மற்றும் கருத்து சுதந்திரம்', 'Freedom of Speech and Expression',
'ஒவ்வொரு குடிமகனுக்கும் தனது கருத்தை சுதந்திரமாக வெளிப்படுத்த உரிமை உள்ளது. பத்திரிகை சுதந்திரம், கருத்துரிமை ஆகியவை இதில் அடங்கும். நியாயமான கட்டுப்பாடுகள் மட்டுமே விதிக்க இயலும்.',
'Every citizen has the right to freely express their opinion. This includes press freedom and right to opinion. Only reasonable restrictions can be imposed.',
'Constitution of India', 'Article 19(1)(a)',
'fundamental',
'1. கருத்து சுதந்திரம் மறுக்கப்பட்டால் காவல் நிலையத்தில் புகார் கொடுக்கலாம்
2. மாநில மனித உரிமை ஆணையத்தில் புகார் அளிக்கலாம்
3. உயர்நீதிமன்றத்தில் அடிப்படை உரிமை மீறலுக்கு ரிட் மனு தாக்கல் செய்யலாம்
4. ஊடக சுதந்திரம் மீறப்பட்டால் பத்திரிகை கவுன்சிலில் புகார் கொடுக்கலாம்',
'1. File a police complaint if freedom of expression is denied
2. Complain to State Human Rights Commission
3. File Writ Petition in High Court for violation of fundamental rights
4. If press freedom is violated, complain to Press Council'),

('கல்வி உரிமை', 'Right to Education',
'6 முதல் 14 வயது வரையிலான அனைத்துக் குழந்தைகளுக்கும் இலவச மற்றும் கட்டாயக் கல்வி. தனியார் பள்ளிகளில் 25% இடஒதுக்கீடு ஏழைக் குழந்தைகளுக்கு உண்டு.',
'Free and compulsory education for all children aged 6 to 14 years. 25% reservation in private schools for economically weaker sections.',
'Right of Children to Free and Compulsory Education Act, 2009', 'Sections 3, 12',
'fundamental',
'1. அருகிலுள்ள அரசு பள்ளியில் சேர்க்கை கேளுங்கள் - மறுக்க இயலாது
2. தனியார் பள்ளிகளில் RTE 25% இடஒதுக்கீடு கோரலாம்
3. RTE இணையதளத்தில் (rte.tnschools.gov.in) விண்ணப்பிக்கலாம்
4. மறுக்கப்பட்டால் மாவட்ட கல்வி அலுவலர் (DEO) அலுவலகத்தில் புகார் கொடுக்கலாம்
5. குழந்தை உதவி எண்: 1098',
'1. Seek admission at nearest government school - cannot be refused
2. Apply for RTE 25% reservation in private schools
3. Apply online at rte.tnschools.gov.in
4. If refused, complain to District Education Officer (DEO)
5. Child helpline: 1098'),

('மத சுதந்திர உரிமை', 'Right to Freedom of Religion',
'எந்த மதத்தையும் தன் விருப்பப்படி பின்பற்றவும், பரப்பவும் உரிமை உண்டு. மத நிறுவனங்களை நிர்வகிக்கவும், மத நிதி நிர்வாகம் செய்யவும் உரிமை.',
'Right to freely profess, practice and propagate any religion. Right to manage religious institutions and administer religious funds.',
'Constitution of India', 'Articles 25, 26',
'fundamental',
'1. மத சுதந்திரம் மறுக்கப்பட்டால் காவல்நிலையத்தில் FIR பதிவு செய்யுங்கள்
2. மாநில சிறுபான்மையினர் ஆணையத்தில் புகார் அளிக்கலாம்
3. தேசிய சிறுபான்மையினர் ஆணையத்தில் புகார் அளிக்கலாம்
4. உயர்நீதிமன்றத்தில் ரிட் மனு தாக்கல் செய்யலாம்',
'1. File an FIR at the police station if religious freedom is denied
2. Complain to State Minority Commission
3. Complain to National Commission for Minorities
4. File Writ Petition in High Court'),

('அரசமைப்பு தீர்வு உரிமை', 'Right to Constitutional Remedies',
'அடிப்படை உரிமைகள் மீறப்பட்டால் நேரடியாக உச்ச நீதிமன்றத்தை அணுகும் உரிமை. இது அனைத்து அடிப்படை உரிமைகளின் இதயம் என்று அழைக்கப்படுகிறது.',
'Right to directly approach the Supreme Court if fundamental rights are violated. This is called the heart and soul of all fundamental rights.',
'Constitution of India', 'Article 32',
'fundamental',
'1. உச்ச நீதிமன்றத்தில் நேரடியாக ரிட் மனு தாக்கல் செய்யலாம்
2. உயர்நீதிமன்றத்தில் பிரிவு 226 கீழ் மனு தாக்கல் செய்யலாம்
3. ஐந்து வகை ரிட் உள்ளன: ஹேபியஸ் கார்பஸ், மாண்டமஸ், செர்ஷியோராரி, ப்ரொஹிபிஷன், குவோ வாரண்டோ
4. இலவச சட்ட உதவி: மாவட்ட சட்ட சேவை ஆணையத்தை அணுகுங்கள்
5. NALSA உதவி எண்: 15100',
'1. File Writ Petition directly in Supreme Court
2. File petition under Article 226 in High Court
3. Five types of writs: Habeas Corpus, Mandamus, Certiorari, Prohibition, Quo Warranto
4. Free legal aid: Contact District Legal Services Authority
5. NALSA helpline: 15100');

-- =============================================
-- CONSUMER RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('தகவல் அறியும் உரிமை (பொருட்கள்)', 'Right to Information about Products',
'வாங்கும் பொருளின் தரம், அளவு, விலை, தயாரிப்பு தேதி, காலாவதி தேதி ஆகிய அனைத்து தகவல்களையும் அறிய நுகர்வோருக்கு உரிமை உண்டு.',
'Consumers have the right to know the quality, quantity, price, manufacturing date, and expiry date of products they purchase.',
'Consumer Protection Act, 2019', 'Section 2(9)',
'consumer',
'1. பொருளின் லேபிளில் அனைத்து தகவல்களும் இருக்க வேண்டும்
2. தகவல் இல்லாவிட்டால் விற்பனையாளரிடம் கேளுங்கள்
3. மறுக்கப்பட்டால் நுகர்வோர் உதவி எண்: 1800-11-4000 (இலவசம்)
4. நுகர்வோர் புகார் இணையதளம்: consumerhelpline.gov.in
5. மாவட்ட நுகர்வோர் நீதிமன்றத்தில் புகார் தாக்கல் செய்யலாம்',
'1. Product labels must contain all information
2. If not available, ask the seller
3. If refused, consumer helpline: 1800-11-4000 (toll-free)
4. Online complaint: consumerhelpline.gov.in
5. File complaint in District Consumer Forum'),

('தேர்வு செய்யும் உரிமை', 'Right to Choose',
'எந்தப் பொருளையும் எந்தக் கடையிலும் வாங்கும் உரிமை. கட்டாய தொகுப்பு விற்பனை (bundling) தடை. ஒரு பொருள் வாங்க மற்றொரு பொருளை வாங்க வேண்டும் என்று கட்டாயப்படுத்த இயலாது.',
'Right to buy any product from any shop. Forced bundling is prohibited. Cannot be forced to buy one product to purchase another.',
'Consumer Protection Act, 2019', 'Section 2(9)(ii)',
'consumer',
'1. கட்டாய தொகுப்பு விற்பனை நடந்தால் ரசீது வாங்குங்கள்
2. நுகர்வோர் உதவி எண்: 1800-11-4000 அழைக்கவும்
3. இணையதளம் வழி புகார்: consumerhelpline.gov.in
4. மாவட்ட நுகர்வோர் நீதிமன்றத்தில் புகார் தாக்கல் செய்யலாம்
5. ரூ.1 கோடி வரை இழப்பீடு பெறலாம்',
'1. Get receipt if forced bundling occurs
2. Call consumer helpline: 1800-11-4000
3. Online complaint: consumerhelpline.gov.in
4. File complaint in District Consumer Forum
5. Can claim compensation up to Rs.1 crore'),

('குறை தீர்க்கும் உரிமை', 'Right to Redress',
'குறையுள்ள பொருள் அல்லது சேவைக்கு இழப்பீடு பெறும் உரிமை. மாற்று பொருள், பணம் திரும்பப் பெறுதல், இழப்பீடு ஆகியவை கோரலாம்.',
'Right to compensation for defective products or services. Can claim replacement, refund, or compensation.',
'Consumer Protection Act, 2019', 'Sections 38, 39',
'consumer',
'1. முதலில் விற்பனையாளரிடம் எழுத்துப்பூர்வமாக புகார் கொடுங்கள்
2. தீர்வு கிடைக்கவில்லை எனில் மாவட்ட நுகர்வோர் நீதிமன்றத்தில் புகார் தாக்கல் செய்யுங்கள்
3. ரூ.1 கோடி வரை - மாவட்ட ஆணையம், ரூ.10 கோடி வரை - மாநில ஆணையம்
4. இணையதளம் வழி புகார்: edaakhil.nic.in
5. வழக்கறிஞர் இல்லாமலே நேரடியாக புகார் அளிக்கலாம்',
'1. First give written complaint to seller
2. If unresolved, file complaint in District Consumer Forum
3. Up to Rs.1 crore - District Commission, up to Rs.10 crore - State Commission
4. Online filing: edaakhil.nic.in
5. Can file complaint directly without a lawyer'),

('கேட்கப்படும் உரிமை', 'Right to be Heard',
'நுகர்வோர் தங்கள் குறைகளை சரியான மேடைகளில் முன்வைக்க உரிமை உண்டு. நுகர்வோர் நீதிமன்றம், நுகர்வோர் அமைப்புகள் மூலம் குரல் எழுப்பலாம்.',
'Consumers have the right to present their grievances on appropriate platforms. Can raise voice through consumer courts and consumer organizations.',
'Consumer Protection Act, 2019', 'Section 2(9)(iv)',
'consumer',
'1. நுகர்வோர் நீதிமன்றத்தில் நேரடியாக புகார் அளிக்கலாம்
2. நுகர்வோர் பாதுகாப்பு அமைப்புகளில் உறுப்பினராகலாம்
3. மத்திய/மாநில நுகர்வோர் பாதுகாப்பு ஆணையத்தில் புகார்
4. ஆன்லைன் தளத்தில் நிறுவனங்களுக்கு எதிராக புகார்: consumerhelpline.gov.in
5. நுகர்வோர் உதவி எண்: 1800-11-4000',
'1. File complaint directly in Consumer Court
2. Join consumer protection organizations
3. Complain to Central/State Consumer Protection Authority
4. Online complaints against companies: consumerhelpline.gov.in
5. Consumer helpline: 1800-11-4000');

-- =============================================
-- WOMEN'S RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('குடும்ப வன்முறை தடுப்பு உரிமை', 'Protection from Domestic Violence',
'உடல் ரீதியான, உணர்ச்சி ரீதியான, பாலியல் ரீதியான, பொருளாதார ரீதியான வன்முறையிலிருந்து பாதுகாப்பு. பாதுகாப்பு உத்தரவு, குடியிருப்பு உத்தரவு, நிதி உதவி ஆகியவை பெறலாம்.',
'Protection from physical, emotional, sexual, and economic violence. Can obtain protection order, residence order, and monetary relief.',
'Protection of Women from Domestic Violence Act, 2005', 'Sections 12, 17, 18, 19, 20',
'women',
'1. அவசர உதவிக்கு பெண்கள் உதவி எண்: 181 அழைக்கவும்
2. அருகிலுள்ள காவல்நிலையத்தில் புகார் கொடுக்கலாம்
3. பாதுகாப்பு அதிகாரி (Protection Officer) மூலம் நீதிமன்றத்தில் மனு
4. மாஜிஸ்திரேட் நீதிமன்றத்தில் நேரடியாக புகார் அளிக்கலாம்
5. இலவச சட்ட உதவி கிடைக்கும் - மாவட்ட சட்ட சேவை ஆணையத்தை அணுகுங்கள்
6. One Stop Centre (சக்தி): 181 என்ற எண்ணில் தொடர்பு கொள்ளுங்கள்',
'1. For emergency, call Women Helpline: 181
2. File complaint at nearest police station
3. Apply through Protection Officer in Magistrate Court
4. Can file complaint directly in Magistrate Court
5. Free legal aid available - Contact District Legal Services Authority
6. One Stop Centre (Sakhi): Call 181'),

('பணியிடத்தில் பாலியல் தொல்லை தடுப்பு', 'Protection from Sexual Harassment at Workplace',
'பணியிடத்தில் எந்தவிதமான பாலியல் தொல்லையும் தடை. ஒவ்வொரு நிறுவனத்திலும் உள்ளக புகார் குழு (ICC) அமைக்க வேண்டும். ஒப்பந்த, தற்காலிக, பயிற்சி ஊழியர்களுக்கும் பொருந்தும்.',
'Any form of sexual harassment at workplace is prohibited. Every organization must constitute an Internal Complaints Committee (ICC). Applies to contract, temporary, and trainee employees too.',
'Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act, 2013', 'Sections 2, 4, 9',
'women',
'1. நிறுவனத்தின் உள்ளக புகார் குழுவிடம் (ICC) எழுத்துப்பூர்வ புகார் கொடுக்கவும்
2. ICC இல்லாவிட்டால் மாவட்ட புகார் குழுவிடம் (LCC) புகார் கொடுக்கலாம்
3. சம்பவம் நடந்த 3 மாதத்திற்குள் புகார் அளிக்க வேண்டும்
4. காவல்நிலையத்தில் FIR பதிவு செய்யலாம் (IPC 354A)
5. பெண்கள் உதவி எண்: 181
6. SHe-box ஆன்லைன் புகார்: shebox.nic.in',
'1. Give written complaint to Internal Complaints Committee (ICC)
2. If no ICC, complain to Local Complaints Committee (LCC)
3. Complaint must be filed within 3 months of incident
4. Can file FIR at police station (IPC 354A)
5. Women helpline: 181
6. SHe-box online complaint: shebox.nic.in'),

('மகப்பேறு சலுகை உரிமை', 'Maternity Benefit Rights',
'26 வாரங்கள் ஊதியத்துடன் கூடிய மகப்பேறு விடுப்பு. முதல் இரண்டு குழந்தைகளுக்கு 26 வாரங்கள், மூன்றாவது குழந்தைக்கு 12 வாரங்கள். கர்ப்ப காலத்தில் பணிநீக்கம் தடை.',
'26 weeks paid maternity leave. 26 weeks for first two children, 12 weeks for third child. Termination during pregnancy is prohibited.',
'Maternity Benefit Act, 1961 (Amended 2017)', 'Sections 5, 5A, 12',
'women',
'1. கர்ப்பம் உறுதியானவுடன் முதலாளியிடம் எழுத்துப்பூர்வமாக தெரிவிக்கவும்
2. விடுப்பு மறுக்கப்பட்டால் தொழிலாளர் துறை அலுவலகத்தில் புகார்
3. தொழிலாளர் ஆணையர் அலுவலகத்தை அணுகலாம்
4. பணிநீக்கம் செய்தால் தொழிலாளர் நீதிமன்றத்தில் வழக்கு தொடரலாம்
5. மத்திய அரசு ஊழியர்கள்: CCS விதிகள் கீழ் 180 நாட்கள் விடுப்பு',
'1. Inform employer in writing once pregnancy is confirmed
2. If leave is denied, complain to Labour Department
3. Approach Labour Commissioner office
4. If terminated, file case in Labour Court
5. Central govt employees: 180 days leave under CCS rules'),

('சொத்துரிமை', 'Women Property Rights',
'இந்து வாரிசு சட்டப்படி மகள்களுக்கு தந்தையின் சொத்தில் மகன்களுக்கு சமமான பங்கு உரிமை. திருமணத்திற்கு முன்னும் பின்னும் இந்த உரிமை பொருந்தும்.',
'Under Hindu Succession Act, daughters have equal share in father''s property as sons. This right applies before and after marriage.',
'Hindu Succession Act, 1956 (Amended 2005)', 'Section 6',
'women',
'1. சொத்துப் பிரிவினை கோரி குடும்பத்தினரிடம் பேசுங்கள்
2. ஒப்புக்கொள்ளவில்லை எனில் நீதிமன்றத்தில் பிரிவினை வழக்கு தாக்கல் செய்யலாம்
3. சொத்து பதிவு அலுவலகத்தில் உரிமை பதிவு செய்யலாம்
4. இலவச சட்ட உதவி: மாவட்ட சட்ட சேவை ஆணையத்தை அணுகுங்கள்
5. வரு வரவு சான்றிதழ் மூலம் வாரிசு உரிமை நிரூபிக்கலாம்',
'1. Discuss property partition with family members
2. If not agreed, file partition suit in court
3. Register rights at Sub-Registrar office
4. Free legal aid: Contact District Legal Services Authority
5. Prove succession rights through legal heir certificate'),

('வரதட்சணை தடை உரிமை', 'Protection from Dowry',
'வரதட்சணை கேட்பது, கொடுப்பது, பெறுவது அனைத்தும் குற்றம். கணவன் மற்றும் அவர் குடும்பத்தினர் வரதட்சணை கொடுமைக்கு தண்டனை பெறுவர்.',
'Demanding, giving, or receiving dowry is a criminal offence. Husband and his family members are punishable for dowry harassment.',
'Dowry Prohibition Act, 1961', 'Sections 3, 4, 8B',
'women',
'1. வரதட்சணை கொடுமை நடந்தால் உடனடியாக 181 அழைக்கவும்
2. காவல்நிலையத்தில் FIR பதிவு செய்யுங்கள் (IPC 498A, DP Act)
3. பெண்கள் காவல்நிலையம் (All Women Police Station) அணுகலாம்
4. குடும்ப நல நீதிமன்றத்தில் வழக்கு தொடரலாம்
5. வரதட்சணை மரணம் நடந்தால் IPC 304B கீழ் வழக்கு
6. One Stop Centre: 181',
'1. If dowry harassment occurs, immediately call 181
2. File FIR at police station (IPC 498A, DP Act)
3. Approach All Women Police Station
4. File case in Family Welfare Court
5. In case of dowry death, case under IPC 304B
6. One Stop Centre: 181');

-- =============================================
-- WORKERS' RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('குறைந்தபட்ச ஊதிய உரிமை', 'Right to Minimum Wages',
'அரசு நிர்ணயித்த குறைந்தபட்ச ஊதியம் பெறும் உரிமை. தமிழ்நாட்டில் தொழில் வாரியாக குறைந்தபட்ச ஊதியம் நிர்ணயிக்கப்படுகிறது. ஊதிய மோசடி செய்வது குற்றம்.',
'Right to receive minimum wages fixed by the government. In Tamil Nadu, minimum wages are fixed industry-wise. Wage fraud is an offence.',
'Minimum Wages Act, 1948 / Code on Wages, 2019', 'Sections 3, 5',
'worker',
'1. ஊதியம் குறைவாக கொடுத்தால் முதலாளியிடம் எழுத்துப்பூர்வமாக கேளுங்கள்
2. தொழிலாளர் ஆணையர் அலுவலகத்தில் புகார் கொடுக்கலாம்
3. மாவட்ட தொழிலாளர் அலுவலகத்தில் மனு கொடுக்கலாம்
4. ஷ்ரம் சுவிதா போர்ட்டல்: shramsuvidha.gov.in
5. தொழிலாளர் உதவி எண்: 14434',
'1. If wages are less, ask employer in writing
2. File complaint at Labour Commissioner office
3. Submit petition at District Labour Office
4. Shram Suvidha Portal: shramsuvidha.gov.in
5. Labour helpline: 14434'),

('வருங்கால வைப்பு நிதி (PF) உரிமை', 'Right to Provident Fund (PF/ESI)',
'20 அல்லது அதற்கு மேற்பட்ட ஊழியர்கள் உள்ள நிறுவனங்களில் PF கட்டாயம். ஊழியர் ஊதியத்தில் 12% PF பிடிக்கப்படும், முதலாளியும் 12% செலுத்த வேண்டும். ESI 10+ ஊழியர்களுக்கு பொருந்தும்.',
'PF is mandatory in establishments with 20+ employees. 12% of employee salary is deducted for PF, employer must also contribute 12%. ESI applies to 10+ employees.',
'Employees'' Provident Funds and Miscellaneous Provisions Act, 1952', 'Sections 2, 6',
'worker',
'1. EPFO உறுப்பினர் போர்ட்டல்: member.epfindia.gov.in இல் PF நிலுவை சரிபாருங்கள்
2. PF பிடிக்கவில்லை எனில் EPFO அலுவலகத்தில் புகார் கொடுக்கலாம்
3. EPF புகார் இணையதளம்: epfigms.gov.in
4. UAN எண் கேளுங்கள் - இது உங்கள் PF கணக்கு எண்
5. PF பணத்தை ஆன்லைனில் எடுக்கலாம்: unifiedportal-mem.epfindia.gov.in',
'1. Check PF balance at member.epfindia.gov.in
2. If PF not deducted, complain to EPFO office
3. EPF complaint portal: epfigms.gov.in
4. Ask for UAN number - your PF account number
5. Withdraw PF online: unifiedportal-mem.epfindia.gov.in'),

('பணிக்கொடை (Gratuity) உரிமை', 'Right to Gratuity',
'ஒரு நிறுவனத்தில் 5 ஆண்டுகள் தொடர்ச்சியாக பணியாற்றினால் பணிக்கொடை பெற உரிமை. 10 அல்லது அதற்கு மேல் ஊழியர்கள் உள்ள நிறுவனங்களுக்கு பொருந்தும். அதிகபட்சம் ரூ.20 லட்சம்.',
'Right to gratuity after 5 years of continuous service. Applies to establishments with 10+ employees. Maximum Rs.20 lakh.',
'Payment of Gratuity Act, 1972', 'Sections 4, 7',
'worker',
'1. பணி ஓய்வு / ராஜினாமா செய்யும்போது Form I-ல் விண்ணப்பிக்கவும்
2. 30 நாட்களுக்குள் முதலாளி பணிக்கொடை வழங்க வேண்டும்
3. வழங்கவில்லை எனில் கட்டுப்படுத்தும் அதிகாரியிடம் (Controlling Authority) புகார்
4. தொழிலாளர் ஆணையர் அலுவலகத்தை அணுகலாம்
5. கணக்கீடு: கடைசி ஊதியம் × 15/26 × பணி ஆண்டுகள்',
'1. Apply in Form I when retiring/resigning
2. Employer must pay gratuity within 30 days
3. If not paid, complain to Controlling Authority
4. Approach Labour Commissioner office
5. Calculation: Last salary × 15/26 × years of service'),

('சம ஊதிய உரிமை', 'Right to Equal Pay',
'ஒரே வேலைக்கு ஆண்-பெண் இருபாலருக்கும் சம ஊதியம் வழங்க வேண்டும். பாலின அடிப்படையிலான ஊதிய பாகுபாடு தடை.',
'Equal pay for equal work for both men and women. Gender-based wage discrimination is prohibited.',
'Equal Remuneration Act, 1976 / Code on Wages, 2019', 'Sections 3, 4',
'worker',
'1. ஊதிய பாகுபாடு இருந்தால் HR துறையிடம் எழுத்துப்பூர்வ புகார் கொடுக்கவும்
2. தொழிலாளர் ஆணையர் அலுவலகத்தில் புகார் அளிக்கலாம்
3. தேசிய பெண்கள் ஆணையத்தில் புகார்: ncw.nic.in
4. தொழிலாளர் நீதிமன்றத்தில் வழக்கு தொடரலாம்
5. தொழிலாளர் உதவி எண்: 14434',
'1. Give written complaint to HR department if wage discrimination exists
2. File complaint at Labour Commissioner office
3. Complain to National Commission for Women: ncw.nic.in
4. File case in Labour Court
5. Labour helpline: 14434'),

('குழந்தை தொழிலாளர் தடை', 'Prohibition of Child Labour',
'14 வயதுக்குட்பட்ட குழந்தைகளை எந்தத் தொழிலிலும் பணியமர்த்துவது தடை. 14-18 வயது இளையோரை ஆபத்தான தொழிலில் பணியமர்த்துவது தடை.',
'Employment of children below 14 years in any occupation is prohibited. Employment of adolescents aged 14-18 in hazardous occupations is prohibited.',
'Child and Adolescent Labour (Prohibition and Regulation) Act, 1986 (Amended 2016)', 'Sections 3, 3A',
'worker',
'1. குழந்தை தொழிலாளர் கண்டால் குழந்தை உதவி எண்: 1098 அழைக்கவும்
2. காவல்நிலையத்தில் FIR பதிவு செய்யலாம்
3. மாவட்ட தொழிலாளர் அலுவலகத்தில் புகார் கொடுக்கலாம்
4. குழந்தை நல குழுவை (CWC) அணுகலாம்
5. PENCIL போர்ட்டல்: pencil.gov.in இல் புகார் பதிவு செய்யலாம்
6. ஒவ்வொரு குற்றத்திற்கும் ரூ.50,000 அபராதம் மற்றும் 2 ஆண்டு சிறை',
'1. If child labour spotted, call Child Helpline: 1098
2. File FIR at police station
3. Complain to District Labour Office
4. Approach Child Welfare Committee (CWC)
5. Report on PENCIL portal: pencil.gov.in
6. Rs.50,000 fine and 2 years imprisonment per offence');

-- =============================================
-- TENANT RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('நியாயமான வாடகை உரிமை', 'Right to Fair Rent',
'வாடகை கட்டுப்பாட்டுச் சட்டப்படி நியாயமான வாடகை நிர்ணயம் செய்யப்படும். தன்னிச்சையாக வாடகை உயர்த்துவது தடை. வாடகை ஒப்பந்தத்தில் குறிப்பிட்டபடி மட்டுமே உயர்வு.',
'Fair rent is determined under Rent Control Act. Arbitrary rent increase is prohibited. Increase only as per rental agreement.',
'Tamil Nadu Buildings (Lease and Rent Control) Act, 1960 / Model Tenancy Act, 2021', 'Sections 3, 4',
'tenant',
'1. அதிகப்படியான வாடகை கேட்டால் வாடகை கட்டுப்பாட்டு நீதிமன்றத்தில் மனு கொடுக்கலாம்
2. நியாயமான வாடகை நிர்ணயம் கோரி மனு செய்யலாம்
3. வாடகை ஒப்பந்தத்தை பதிவு செய்து வைத்துக்கொள்ளுங்கள்
4. வாடகை ரசீது வாங்குவது முக்கியம்
5. மாவட்ட ஆட்சியர் அலுவலகத்தில் புகார் கொடுக்கலாம்',
'1. If excessive rent is demanded, file petition in Rent Control Court
2. Apply for fair rent determination
3. Keep rental agreement registered
4. Getting rent receipts is important
5. Can complain to District Collector office'),

('வெளியேற்றல் பாதுகாப்பு உரிமை', 'Protection from Illegal Eviction',
'சட்டவிரோதமாக வாடகைதாரரை வெளியேற்ற முடியாது. நீதிமன்ற உத்தரவு இல்லாமல் வெளியேற்றம் தடை. வெளியேற்றத்திற்கு குறிப்பிட்ட காரணங்கள் மட்டுமே செல்லும்.',
'Tenants cannot be illegally evicted. Eviction without court order is prohibited. Only specific grounds are valid for eviction.',
'Tamil Nadu Buildings (Lease and Rent Control) Act, 1960', 'Sections 10, 14',
'tenant',
'1. சட்டவிரோத வெளியேற்றம் நடந்தால் உடனடியாக காவல்நிலையத்தில் புகார் கொடுக்கவும்
2. வாடகை கட்டுப்பாட்டு நீதிமன்றத்தில் தடை உத்தரவு கோரலாம்
3. வழக்கறிஞர் மூலம் தற்காலிக தடை உத்தரவு (Injunction) பெறலாம்
4. நீர், மின் இணைப்பு துண்டிக்கப்பட்டால் அது சட்டவிரோதம் - புகார் கொடுக்கலாம்
5. இலவச சட்ட உதவி: மாவட்ட சட்ட சேவை ஆணையம் (DLSA)',
'1. If illegal eviction occurs, immediately file police complaint
2. Seek stay order in Rent Control Court
3. Get temporary injunction through lawyer
4. Disconnection of water/electricity is illegal - file complaint
5. Free legal aid: District Legal Services Authority (DLSA)'),

('வைப்புத்தொகை திரும்பப்பெறும் உரிமை', 'Right to Security Deposit Refund',
'வாடகை முடிவடையும்போது வைப்புத்தொகை (Advance) திரும்பப்பெற உரிமை. சொத்துக்கு சேதம் இல்லாவிட்டால் முழு வைப்புத்தொகையும் திரும்ப கிடைக்கும்.',
'Right to get security deposit back when tenancy ends. Full deposit refundable if no damage to property.',
'Tamil Nadu Buildings (Lease and Rent Control) Act, 1960 / Model Tenancy Act, 2021', 'Section 3',
'tenant',
'1. வாடகை ஒப்பந்தத்தில் வைப்புத்தொகை குறிப்பு இருக்க வேண்டும்
2. வைப்புத்தொகை ரசீது வைத்திருங்கள்
3. வீடு காலி செய்யும்போது எழுத்துப்பூர்வமாக வைப்புத்தொகை கேளுங்கள்
4. திரும்பத் தரவில்லை எனில் வழக்கறிஞர் நோட்டீஸ் அனுப்பலாம்
5. சிவில் நீதிமன்றத்தில் வழக்கு தொடரலாம்
6. மாவட்ட ஆட்சியர் அலுவலகத்தில் புகார் கொடுக்கலாம்',
'1. Security deposit must be mentioned in rental agreement
2. Keep security deposit receipt
3. When vacating, ask for deposit in writing
4. If not returned, send lawyer notice
5. File case in Civil Court
6. Complain to District Collector office');

-- =============================================
-- RTI RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('தகவல் அறியும் உரிமை', 'Right to Information (RTI)',
'எந்த அரசு அலுவலகத்திடமும் தகவல் கேட்கும் உரிமை. 30 நாட்களுக்குள் பதில் அளிக்க வேண்டும். உயிருக்கு ஆபத்தான விஷயங்களில் 48 மணி நேரத்தில் பதில்.',
'Right to seek information from any government office. Must respond within 30 days. In life-threatening matters, response within 48 hours.',
'Right to Information Act, 2005', 'Sections 3, 6, 7',
'rti',
'1. ரூ.10 கட்டணத்துடன் RTI விண்ணப்பம் அருகிலுள்ள அரசு அலுவலகத்தில் கொடுக்கலாம்
2. ஆன்லைன் RTI: rtionline.gov.in (மத்திய அரசு), rtionline.tn.gov.in (தமிழ்நாடு)
3. பதில் வரவில்லை எனில் 30 நாட்களுக்குப் பிறகு முதல் மேல்முறையீடு
4. அதிலும் பதில் இல்லையெனில் தகவல் ஆணையத்தில் இரண்டாம் மேல்முறையீடு
5. BPL குடும்பத்தினருக்கு கட்டணம் இல்லை
6. தகவல் மறுப்புக்கு அதிகாரிக்கு ரூ.25,000 அபராதம் விதிக்கலாம்',
'1. Submit RTI application with Rs.10 fee at any government office
2. Online RTI: rtionline.gov.in (Central), rtionline.tn.gov.in (Tamil Nadu)
3. If no response, first appeal after 30 days
4. If still no response, second appeal to Information Commission
5. No fee for BPL families
6. Officer can be fined Rs.25,000 for denying information'),

('RTI மேல்முறையீட்டு உரிமை', 'Right to RTI Appeal',
'RTI பதில் திருப்திகரமாக இல்லை எனில் மேல்முறையீடு செய்யும் உரிமை. முதல் மேல்முறையீடு அதே துறையிலும், இரண்டாவது தகவல் ஆணையத்திலும் செய்யலாம்.',
'Right to appeal if RTI response is unsatisfactory. First appeal within the same department, second appeal to Information Commission.',
'Right to Information Act, 2005', 'Sections 19(1), 19(3)',
'rti',
'1. பதில் வந்த 30 நாட்களுக்குள் முதல் மேல்முறையீட்டு அதிகாரியிடம் மனு
2. முதல் மேல்முறையீட்டிற்கு பதில் வராவிட்டால் 90 நாட்களுக்குள் இரண்டாம் மேல்முறையீடு
3. மாநில தகவல் ஆணையம்: www.tn.gov.in/sic
4. மத்திய தகவல் ஆணையம்: cic.gov.in
5. மேல்முறையீட்டிற்கு கட்டணம் இல்லை
6. ஆணையர் நேரில் விசாரணை நடத்துவார்',
'1. File first appeal to First Appellate Authority within 30 days of response
2. If no response to first appeal, second appeal within 90 days
3. State Information Commission: www.tn.gov.in/sic
4. Central Information Commission: cic.gov.in
5. No fee for appeals
6. Commissioner will conduct hearing in person');

-- =============================================
-- DIGITAL RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('தனியுரிமை மற்றும் தரவு பாதுகாப்பு உரிமை', 'Right to Privacy and Data Protection',
'ஒவ்வொரு நபரின் தனிப்பட்ட தகவல்களும் பாதுகாக்கப்பட வேண்டும். சம்மதம் இல்லாமல் தனிப்பட்ட தகவல்களை சேகரிப்பது, பகிர்வது தடை. தரவு நீக்கம் கோரும் உரிமை உள்ளது.',
'Every person''s personal data must be protected. Collection or sharing of personal data without consent is prohibited. Right to request data deletion exists.',
'Digital Personal Data Protection Act, 2023', 'Sections 4, 5, 6, 12',
'digital',
'1. தரவு மீறல் நடந்தால் அந்த நிறுவனத்தின் தரவு பாதுகாப்பு அதிகாரியிடம் புகார்
2. சைபர் குற்றம் புகார்: cybercrime.gov.in
3. சைபர் குற்ற உதவி எண்: 1930
4. தரவு பாதுகாப்பு வாரியத்தில் புகார் அளிக்கலாம்
5. உங்கள் தரவை நீக்கக் கோரும் உரிமை உள்ளது - நிறுவனத்திடம் கோருங்கள்
6. சம்மதம் எப்போது வேண்டுமானாலும் திரும்பப்பெறலாம்',
'1. If data breach occurs, complain to organization''s Data Protection Officer
2. Cyber crime complaint: cybercrime.gov.in
3. Cyber crime helpline: 1930
4. File complaint with Data Protection Board
5. Right to request data deletion - demand from organization
6. Consent can be withdrawn at any time'),

('சைபர் குற்றங்களிலிருந்து பாதுகாப்பு', 'Protection from Cyber Crimes',
'ஆன்லைன் மோசடி, அடையாள திருட்டு, சைபர் பிரபலம், ஆபாச உள்ளடக்கம் பகிர்தல் ஆகியவை சைபர் குற்றங்கள். 3-7 ஆண்டுகள் சிறைத்தண்டனை விதிக்கப்படும்.',
'Online fraud, identity theft, cyberstalking, sharing obscene content are cyber crimes. 3-7 years imprisonment can be imposed.',
'Information Technology Act, 2000', 'Sections 43, 66, 66A, 66C, 66D, 67',
'digital',
'1. cybercrime.gov.in இல் புகார் பதிவு செய்யுங்கள்
2. சைபர் குற்ற உதவி எண்: 1930
3. அருகிலுள்ள காவல்நிலையத்தில் FIR பதிவு செய்யலாம்
4. சைபர் குற்ற காவல்நிலையத்தில் நேரடியாக புகார் அளிக்கலாம்
5. ஆதாரங்களை (screenshots, messages) பாதுகாப்பாக வைத்திருங்கள்
6. வங்கி மோசடி நடந்தால் உடனடியாக வங்கியை அழைத்து கார்டை முடக்குங்கள்',
'1. Register complaint at cybercrime.gov.in
2. Cyber crime helpline: 1930
3. File FIR at nearest police station
4. File complaint directly at Cyber Crime Police Station
5. Preserve evidence (screenshots, messages)
6. If bank fraud, immediately call bank and block card');

-- =============================================
-- SC/ST RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('தீண்டாமை ஒழிப்பு மற்றும் கொடுமை தடுப்பு', 'Prevention of Atrocities against SC/ST',
'ஆதிதிராவிடர் மற்றும் பழங்குடியினர் மீது கொடுமை செய்வது, சாதி அடிப்படையில் அவமதிப்பது, பொது இடங்களில் அனுமதி மறுப்பது ஆகியவை குற்றம். கடுமையான தண்டனை விதிக்கப்படும்.',
'Committing atrocities against SC/ST, insulting on caste basis, denying access to public places are offences. Severe punishment will be imposed.',
'Scheduled Castes and Scheduled Tribes (Prevention of Atrocities) Act, 1989 (Amended 2015)', 'Sections 3, 4, 14',
'sc_st',
'1. உடனடியாக அருகிலுள்ள காவல்நிலையத்தில் FIR பதிவு செய்யுங்கள்
2. காவல்துறை FIR பதிவு செய்ய மறுத்தால் SP/DSP அலுவலகத்தில் புகார்
3. SC/ST ஆணையத்தில் புகார்: ncsc.nic.in / ncst.nic.in
4. மாவட்ட ஆட்சியர் அலுவலகத்தில் மனு கொடுக்கலாம்
5. பாதிக்கப்பட்டவருக்கு இழப்பீடு பெற உரிமை உள்ளது
6. இலவச சட்ட உதவி: DLSA - 15100
7. SC/ST உதவி எண்: 14566',
'1. Immediately file FIR at nearest police station
2. If police refuse FIR, complain to SP/DSP office
3. Complain to SC/ST Commission: ncsc.nic.in / ncst.nic.in
4. Submit petition to District Collector office
5. Victim has right to receive compensation
6. Free legal aid: DLSA - 15100
7. SC/ST helpline: 14566'),

('இடஒதுக்கீடு உரிமை', 'Right to Reservation',
'கல்வி நிறுவனங்கள் மற்றும் அரசு வேலையில் ஆதிதிராவிடர் (SC) 18%, பழங்குடியினர் (ST) 1% இடஒதுக்கீடு தமிழ்நாட்டில் உள்ளது. பதவி உயர்வு, வயது தளர்வு, கட்டண விலக்கு ஆகிய சலுகைகளும் உள்ளன.',
'In Tamil Nadu, SC has 18% and ST has 1% reservation in educational institutions and government jobs. Benefits include promotion, age relaxation, and fee exemption.',
'Constitution of India / Tamil Nadu Reservation Act', 'Articles 15(4), 16(4), 46',
'sc_st',
'1. சாதி சான்றிதழ் (Community Certificate) வட்டாட்சியர் அலுவலகத்தில் பெறுங்கள்
2. கல்வி சேர்க்கையில் இடஒதுக்கீடு கோருங்கள்
3. அரசு வேலை விண்ணப்பத்தில் சாதி குறிப்பிடுங்கள்
4. இடஒதுக்கீடு மறுக்கப்பட்டால் SC/ST ஆணையத்தில் புகார்
5. ஆதிதிராவிடர் நல அலுவலகத்தை அணுகலாம்
6. இலவச பயிற்சி மையங்கள் பற்றி taluk அலுவலகத்தில் விசாரிக்கலாம்',
'1. Get Community Certificate from Taluk office
2. Claim reservation in educational admissions
3. Mention caste in government job applications
4. If reservation denied, complain to SC/ST Commission
5. Approach Adi Dravidar Welfare Office
6. Enquire about free coaching centres at taluk office');

-- =============================================
-- SENIOR CITIZEN RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('பராமரிப்பு உரிமை (முதியோர்)', 'Right to Maintenance (Senior Citizens)',
'பிள்ளைகள் அல்லது உறவினர்கள் முதியோரை கவனிக்க வேண்டும். கவனிக்கவில்லை எனில் பராமரிப்பு தீர்ப்பாயம் மூலம் மாதாந்திர பராமரிப்புத் தொகை பெறலாம். அதிகபட்சம் ரூ.10,000.',
'Children or relatives must take care of senior citizens. If not cared for, can get monthly maintenance through Maintenance Tribunal. Maximum Rs.10,000.',
'Maintenance and Welfare of Parents and Senior Citizens Act, 2007', 'Sections 4, 5, 9',
'senior',
'1. மாவட்ட ஆட்சியர் அலுவலகத்தில் பராமரிப்பு தீர்ப்பாயத்தில் மனு கொடுக்கவும்
2. SDM (உதவி மாவட்ட ஆட்சியர்) முன் விசாரணை நடக்கும்
3. 90 நாட்களுக்குள் உத்தரவு பிறப்பிக்கப்படும்
4. மாத பராமரிப்புத் தொகை நிர்ணயிக்கப்படும்
5. உத்தரவை மீறினால் 3 மாத சிறைத்தண்டனை
6. மூத்த குடிமக்கள் உதவி எண்: 14567
7. வழக்கறிஞர் தேவையில்லை - நேரடியாக மனு கொடுக்கலாம்',
'1. Submit petition to Maintenance Tribunal at District Collector office
2. Hearing before SDM (Sub-Divisional Magistrate)
3. Order will be issued within 90 days
4. Monthly maintenance amount will be fixed
5. Violation of order: 3 months imprisonment
6. Senior Citizens Helpline: 14567
7. No lawyer needed - can file petition directly'),

('முதியோர் சொத்து பாதுகாப்பு உரிமை', 'Senior Citizen Property Protection Rights',
'முதியோர் தங்கள் சொத்தை பிள்ளைகளுக்கு மாற்றிய பின் புறக்கணிக்கப்பட்டால், அந்த சொத்து மாற்றத்தை ரத்து செய்யலாம். பராமரிப்பு நிபந்தனையுடன் சொத்து மாற்றம் செய்யப்பட்டிருந்தால் மீறலுக்கு நடவடிக்கை எடுக்கலாம்.',
'If senior citizens are neglected after transferring property to children, the transfer can be cancelled. Action can be taken for violation if property was transferred with maintenance condition.',
'Maintenance and Welfare of Parents and Senior Citizens Act, 2007', 'Section 23',
'senior',
'1. சொத்து மாற்றம் ரத்து கோரி சிவில் நீதிமன்றத்தில் வழக்கு தொடரலாம்
2. பராமரிப்பு தீர்ப்பாயத்தில் மனு கொடுக்கலாம்
3. காவல்நிலையத்தில் புறக்கணிப்பு புகார் கொடுக்கலாம்
4. நிலப்பதிவு அலுவலகத்தில் சொத்து மாற்றம் ரத்து செய்யலாம்
5. இலவச சட்ட உதவி: மாவட்ட சட்ட சேவை ஆணையம்
6. மூத்த குடிமக்கள் உதவி எண்: 14567',
'1. File case in Civil Court for cancellation of property transfer
2. Submit petition to Maintenance Tribunal
3. File neglect complaint at police station
4. Cancel property transfer at Sub-Registrar office
5. Free legal aid: District Legal Services Authority
6. Senior Citizens Helpline: 14567');

-- =============================================
-- LAND / PROPERTY RIGHTS
-- =============================================

INSERT INTO legal_rights (title_tamil, title_english, description_tamil, description_english, act_name, section, category, how_to_claim_tamil, how_to_claim_english) VALUES
('பட்டா உரிமை', 'Patta (Land Title) Rights',
'நிலத்தின் உரிமையாளருக்கு பட்டா (நில உரிமை ஆவணம்) பெற உரிமை. பட்டா நில உரிமையை நிரூபிக்கும் முக்கிய ஆவணம். பட்டா இல்லாமல் நில பரிவர்த்தனை செய்ய இயலாது.',
'Land owner has the right to obtain Patta (land title document). Patta is the key document proving land ownership. Land transactions cannot be done without Patta.',
'Tamil Nadu Land Reforms (Fixation of Ceiling on Land) Act, 1961 / Tamil Nadu Survey and Boundaries Act, 1923', 'Various Sections',
'property',
'1. வட்டாட்சியர் (Tahsildar) அலுவலகத்தில் பட்டா விண்ணப்பிக்கலாம்
2. ஆன்லைன் விண்ணப்பம்: eservices.tn.gov.in
3. தேவையான ஆவணங்கள்: விற்பனை ஆவணம், அடங்கல், சிட்டா, வரி ரசீது
4. 30 நாட்களுக்குள் பட்டா மாற்றம் செய்யப்பட வேண்டும்
5. மறுக்கப்பட்டால் மாவட்ட வருவாய் அலுவலர் (RDO) இடம் மேல்முறையீடு
6. ஆன்லைன் பட்டா/சிட்டா பார்க்க: patta.tn.gov.in',
'1. Apply for Patta at Tahsildar office
2. Online application: eservices.tn.gov.in
3. Required documents: Sale deed, Adangal, Chitta, tax receipt
4. Patta transfer should be done within 30 days
5. If refused, appeal to Revenue Divisional Officer (RDO)
6. View Patta/Chitta online: patta.tn.gov.in'),

('நில அளவை மற்றும் எல்லை உரிமை', 'Land Survey and Boundary Rights (TSLR)',
'நிலத்தின் எல்லைகளை சரிபார்க்கவும், அளவை செய்யவும் கோரும் உரிமை. நில எல்லை தகராறுகளில் TSLR அளவை மூலம் தீர்வு பெறலாம்.',
'Right to verify and survey land boundaries. Land boundary disputes can be resolved through TSLR survey.',
'Tamil Nadu Survey and Boundaries Act, 1923', 'Sections 7, 8, 9',
'property',
'1. வட்டாட்சியர் அலுவலகத்தில் நில அளவை கோரி விண்ணப்பிக்கலாம்
2. கிராம நிர்வாக அலுவலர் (VAO) மூலம் விண்ணப்பம் செய்யலாம்
3. அளவைத் தொகை செலுத்த வேண்டும்
4. அளவை முடிவு திருப்திகரமாக இல்லையெனில் மாவட்ட ஆட்சியரிடம் மேல்முறையீடு
5. நில எல்லை தகராறு சிவில் நீதிமன்றத்தில் வழக்கு தொடரலாம்
6. FMB (Field Measurement Book) நகல் பெற வட்டாட்சியர் அலுவலகத்தை அணுகலாம்',
'1. Apply for land survey at Tahsildar office
2. Can apply through Village Administrative Officer (VAO)
3. Survey fee must be paid
4. If survey result unsatisfactory, appeal to District Collector
5. Land boundary dispute can be filed in Civil Court
6. Get FMB (Field Measurement Book) copy from Tahsildar office'),

('குத்தகை விவசாயி உரிமை', 'Tenant Farmer Rights',
'நிலத்தை குத்தகைக்கு விவசாயம் செய்யும் விவசாயிகளுக்கு பாதுகாப்பு. சட்டவிரோதமாக நிலத்திலிருந்து வெளியேற்ற இயலாது. நியாயமான குத்தகை விகிதம் பெறும் உரிமை.',
'Protection for tenant farmers cultivating leased land. Cannot be illegally evicted from land. Right to fair lease rate.',
'Tamil Nadu Land Reforms (Fixation of Ceiling on Land) Act, 1961', 'Sections 4, 5, 6',
'property',
'1. குத்தகை ஒப்பந்தத்தை எழுத்துப்பூர்வமாக வைத்திருங்கள்
2. வெளியேற்றம் நடந்தால் வட்டாட்சியர் அலுவலகத்தில் புகார் கொடுக்கலாம்
3. விவசாய தீர்ப்பாயத்தில் மனு கொடுக்கலாம்
4. மாவட்ட ஆட்சியர் அலுவலகத்தில் மனு கொடுக்கலாம்
5. விவசாயிகள் உதவி எண்: 1800-180-1551 (Kisan Call Centre)
6. வேளாண் துறை அலுவலகத்தை அணுகலாம்',
'1. Keep lease agreement in writing
2. If evicted, complain at Tahsildar office
3. File petition in Agricultural Tribunal
4. Submit petition to District Collector office
5. Farmers helpline: 1800-180-1551 (Kisan Call Centre)
6. Approach Agriculture Department office');
