-- Cyber Safety Tips Data
-- Cyber safety guidelines for Tamil Nadu residents
-- Safety-critical data for VAZHI Tamil AI assistant

DELETE FROM cyber_safety_tips;

-- ============================================================
-- PASSWORD SAFETY (category: 'password')
-- ============================================================

INSERT INTO cyber_safety_tips (title_tamil, title_english, tip_tamil, tip_english, category, priority) VALUES
(
    'வலுவான கடவுச்சொல் உருவாக்குங்கள்',
    'Create Strong Passwords',
    'குறைந்தது 12 எழுத்துகள் கொண்ட கடவுச்சொல் பயன்படுத்துங்கள். பெரிய எழுத்து, சிறிய எழுத்து, எண்கள், சிறப்பு குறியீடுகள் (!@#$) கலந்து பயன்படுத்துங்கள். உங்கள் பெயர், பிறந்த தேதி, தொலைபேசி எண் ஆகியவற்றை கடவுச்சொல்லாக பயன்படுத்தாதீர்கள்.',
    'Use passwords with at least 12 characters. Mix uppercase, lowercase, numbers, and special characters (!@#$). Never use your name, birthday, or phone number as password.',
    'password',
    1
),
(
    'ஒவ்வொரு கணக்குக்கும் தனி கடவுச்சொல்',
    'Use Unique Passwords for Each Account',
    'ஒரே கடவுச்சொல்லை பல கணக்குகளுக்கு பயன்படுத்தாதீர்கள். வங்கி, Email, சமூக ஊடகம் ஒவ்வொன்றுக்கும் தனித்தனி கடவுச்சொல் வைக்கவும். கடவுச்சொல்லை நினைவில் வைக்க முடியாவிட்டால் Google Password Manager அல்லது நம்பகமான Password Manager ஆப் பயன்படுத்தவும்.',
    'Do not reuse the same password across multiple accounts. Keep separate passwords for bank, email, and social media. Use Google Password Manager or a trusted password manager app if you cannot remember them.',
    'password',
    1
),
(
    'இரண்டு-படி சரிபார்ப்பு (2FA) இயக்குங்கள்',
    'Enable Two-Factor Authentication (2FA)',
    'Gmail, WhatsApp, Facebook, Instagram ஆகிய அனைத்து கணக்குகளிலும் 2FA/Two-Step Verification இயக்குங்கள். இது உங்கள் கடவுச்சொல் திருடப்பட்டாலும் கணக்கைப் பாதுகாக்கும். SMS OTP-ஐ விட Google Authenticator ஆப் பாதுகாப்பானது.',
    'Enable 2FA/Two-Step Verification on all accounts including Gmail, WhatsApp, Facebook, Instagram. This protects your account even if password is stolen. Google Authenticator app is safer than SMS OTP.',
    'password',
    1
),
(
    'OTP-ஐ யாரிடமும் பகிராதீர்கள்',
    'Never Share OTP with Anyone',
    'OTP (One Time Password) என்பது உங்கள் பணத்தின் சாவி. வங்கி ஊழியர், போலீஸ், அரசு அதிகாரி யாராக இருந்தாலும் OTP கேட்டால் மோசடி. எந்த சூழ்நிலையிலும் OTP-ஐ தொலைபேசி, SMS, WhatsApp மூலம் பகிராதீர்கள்.',
    'OTP (One Time Password) is the key to your money. If anyone asks for OTP - bank employee, police, or govt official - it is a scam. Never share OTP via phone, SMS, or WhatsApp under any circumstance.',
    'password',
    1
);

-- ============================================================
-- BANKING SAFETY (category: 'banking')
-- ============================================================

INSERT INTO cyber_safety_tips (title_tamil, title_english, tip_tamil, tip_english, category, priority) VALUES
(
    'பாதுகாப்பான UPI பயன்பாடு',
    'Safe UPI Usage',
    'பணம் பெற ஒருபோதும் UPI PIN தேவையில்லை என்பதை நினைவில் கொள்ளுங்கள். அறியாதவர்களின் UPI Request-ஐ நிராகரிக்கவும். QR கோட் ஸ்கேன் செய்வது பணம் அனுப்புவதற்கே. UPI PIN-ஐ யாரிடமும் பகிராதீர்கள். GPay, PhonePe ஆப்பில் Auto-Pay Limit குறைவாக வையுங்கள்.',
    'Remember you never need UPI PIN to receive money. Decline UPI requests from unknown people. Scanning QR code is for sending money only. Never share UPI PIN. Set low Auto-Pay Limit in GPay, PhonePe app.',
    'banking',
    1
),
(
    'இணையவழி வங்கிப் பாதுகாப்பு',
    'Secure Internet Banking',
    'வங்கியின் அதிகாரப்பூர்வ ஆப் அல்லது இணையதளத்தை மட்டுமே பயன்படுத்துங்கள். URL-ல் https:// மற்றும் பூட்டு அடையாளம் இருப்பதை சரிபார்க்கவும். பொது WiFi-யில் வங்கி பரிவர்த்தனை செய்யாதீர்கள். வங்கி பரிவர்த்தனை முடிந்ததும் Logout செய்யுங்கள்.',
    'Use only official bank app or website. Check for https:// and lock icon in URL. Never do banking transactions on public WiFi. Always logout after banking transactions.',
    'banking',
    1
),
(
    'ATM பாதுகாப்பு குறிப்புகள்',
    'ATM Safety Tips',
    'ATM-ல் PIN டைப் செய்யும்போது கையால் மறைக்கவும். அறியாதவர்கள் உதவி செய்ய வந்தால் மறுக்கவும். ATM கார்டு நுழைக்கும் இடத்தில் கூடுதல் சாதனம் இருக்கிறதா சரிபார்க்கவும் (Skimmer). பரிவர்த்தனை முடிந்ததும் ரசீதை எடுக்கவும்.',
    'Cover keypad while entering ATM PIN. Refuse help from strangers at ATM. Check for extra devices on card slot (Skimmer). Always take receipt after transaction.',
    'banking',
    2
),
(
    'வங்கி SMS எச்சரிக்கைகள் இயக்குங்கள்',
    'Enable Bank SMS Alerts',
    'உங்கள் வங்கிக் கணக்கில் SMS மற்றும் Email எச்சரிக்கைகளை இயக்குங்கள். ஒவ்வொரு பரிவர்த்தனைக்கும் SMS வரும். நீங்கள் செய்யாத பரிவர்த்தனை SMS வந்தால் உடனே வங்கிக்கு தெரிவிக்கவும். Transaction limit-ஐ குறைவாக வைக்கவும்.',
    'Enable SMS and Email alerts on your bank account. You will receive SMS for every transaction. If you get an SMS for a transaction you did not make, immediately inform the bank. Keep transaction limit low.',
    'banking',
    1
);

-- ============================================================
-- SOCIAL MEDIA SAFETY (category: 'social_media')
-- ============================================================

INSERT INTO cyber_safety_tips (title_tamil, title_english, tip_tamil, tip_english, category, priority) VALUES
(
    'WhatsApp தனியுரிமை அமைப்புகள்',
    'WhatsApp Privacy Settings',
    'WhatsApp Settings > Privacy-ல் Profile Photo, Last Seen, About ஆகியவற்றை "My Contacts" அல்லது "Nobody" என மாற்றவும். குழுக்களில் சேர்ப்பதை "My Contacts" என வரையறுக்கவும். அறியாத எண்களிலிருந்து வரும் அழைப்புகளை அமைதிப்படுத்துங்கள் (Silence unknown callers).',
    'In WhatsApp Settings > Privacy, change Profile Photo, Last Seen, About to "My Contacts" or "Nobody". Restrict group additions to "My Contacts". Enable "Silence unknown callers" feature.',
    'social_media',
    2
),
(
    'சமூக ஊடகத்தில் தனிப்பட்ட தகவல் பாதுகாப்பு',
    'Protect Personal Info on Social Media',
    'Facebook, Instagram-ல் தொலைபேசி எண், முகவரி, பிறந்த தேதி ஆகியவற்றை பொதுவாக (Public) பகிராதீர்கள். விடுமுறைக்குச் செல்லும் தகவலை பகிராதீர்கள். குழந்தைகளின் புகைப்படங்களை Public-ல் போடாதீர்கள். Location Tag-ஐ முடக்கவும்.',
    'Do not share phone number, address, or birthday publicly on Facebook and Instagram. Do not share vacation plans. Do not post children photos publicly. Disable Location Tag.',
    'social_media',
    2
),
(
    'சமூக ஊடக கணக்கு பாதுகாப்பு',
    'Social Media Account Security',
    'Facebook, Instagram, Twitter கணக்குகளில் Login Alerts இயக்கவும். அறியாத சாதனங்களிலிருந்து உள்நுழைவு அறிவிப்பு வரும். Trusted Contacts அமைக்கவும். 3rd party ஆப்களுக்கு கொடுத்த அணுகலை சரிபார்த்து நீக்கவும்.',
    'Enable Login Alerts on Facebook, Instagram, Twitter accounts. You will get notifications of logins from unknown devices. Set up Trusted Contacts. Review and remove access given to 3rd party apps.',
    'social_media',
    2
),
(
    'WhatsApp-ல் வரும் லிங்க்களை சரிபார்க்கவும்',
    'Verify Links Received on WhatsApp',
    'WhatsApp-ல் ஃபார்வர்ட் செய்யப்பட்ட லிங்க்களை கிளிக் செய்யாதீர்கள். அரசு திட்டம், இலவச பரிசு என்ற செய்திகளை நம்பாதீர்கள். .xyz, .win, .top போன்ற domain-கள் இருந்தால் மோசடி. சந்தேகமான செய்திகளை "Report" செய்யுங்கள்.',
    'Do not click forwarded links on WhatsApp. Do not believe messages about govt schemes or free gifts. Domains like .xyz, .win, .top are scams. Report suspicious messages.',
    'social_media',
    1
);

-- ============================================================
-- DEVICE SAFETY (category: 'device')
-- ============================================================

INSERT INTO cyber_safety_tips (title_tamil, title_english, tip_tamil, tip_english, category, priority) VALUES
(
    'பொது WiFi பாதுகாப்பு',
    'Public WiFi Safety',
    'கடை, ரயில் நிலையம், விமான நிலையம் போன்ற இடங்களில் உள்ள இலவச WiFi-யில் வங்கி பரிவர்த்தனை, UPI Payment செய்யாதீர்கள். பொது WiFi-யில் கடவுச்சொல் உள்ளிடாதீர்கள். தேவையெனில் VPN பயன்படுத்துங்கள். பயன்படுத்தாதபோது WiFi-ஐ அணைக்கவும்.',
    'Do not do banking or UPI transactions on free WiFi at shops, railway stations, airports. Do not enter passwords on public WiFi. Use VPN if needed. Turn off WiFi when not in use.',
    'device',
    1
),
(
    'பொது சார்ஜிங் போர்ட் ஆபத்து (Juice Jacking)',
    'Public Charging Port Risk (Juice Jacking)',
    'ரயில் நிலையம், பேருந்து நிலையம், விமான நிலையம் போன்ற இடங்களில் உள்ள USB சார்ஜிங் போர்ட்களை பயன்படுத்தாதீர்கள். இவை மூலம் உங்கள் தொலைபேசியிலிருந்து தகவல் திருடப்படலாம். உங்கள் சொந்த சார்ஜர் மற்றும் Power Bank எடுத்துச் செல்லுங்கள்.',
    'Do not use USB charging ports at railway stations, bus stands, airports. Data can be stolen from your phone through these ports. Carry your own charger and power bank.',
    'device',
    2
),
(
    'ஆப் அனுமதிகளை கட்டுப்படுத்துங்கள்',
    'Control App Permissions',
    'ஆப்கள் கேட்கும் அனைத்து அனுமதிகளையும் கொடுக்க வேண்டாம். Calculator ஆப் Camera அணுகல் கேட்டால் கொடுக்க வேண்டாம். Settings > Apps > Permissions-ல் தேவையற்ற அனுமதிகளை நீக்கவும். கடன் ஆப்களுக்கு Contacts, Gallery அணுகல் கொடுக்காதீர்கள்.',
    'Do not grant all permissions that apps request. If a calculator app asks camera access, do not grant it. Remove unnecessary permissions in Settings > Apps > Permissions. Never give Contacts and Gallery access to loan apps.',
    'device',
    1
),
(
    'போலி ஆப்களை அடையாளம் காணுங்கள்',
    'Identify Fake Apps',
    'Google Play Store-ல் மட்டும் ஆப் பதிவிறக்கவும். ஆப் பதிவிறக்கும் முன் Reviews, Ratings, Developer பெயர் சரிபார்க்கவும். மிகக் குறைந்த Downloads உள்ள ஆப்களை தவிர்க்கவும். APK file-களை WhatsApp அல்லது இணையதளத்திலிருந்து பதிவிறக்காதீர்கள்.',
    'Download apps only from Google Play Store. Check Reviews, Ratings, and Developer name before downloading. Avoid apps with very few downloads. Do not download APK files from WhatsApp or websites.',
    'device',
    1
),
(
    'தொலைபேசி பூட்டு பாதுகாப்பு',
    'Phone Lock Security',
    'தொலைபேசியில் PIN, Pattern, அல்லது Fingerprint Lock அமைக்கவும். எளிய Pattern (L, Z வடிவம்) தவிர்க்கவும். 6 இலக்க PIN பயன்படுத்துங்கள். Find My Device இயக்கவும். தொலைபேசி தொலைந்தால் உடனே remote wipe செய்யவும்.',
    'Set PIN, Pattern, or Fingerprint Lock on your phone. Avoid simple patterns (L, Z shapes). Use 6-digit PIN. Enable Find My Device. If phone is lost, immediately do remote wipe.',
    'device',
    1
),
(
    'தொலைபேசி மென்பொருள் புதுப்பிப்பு',
    'Keep Phone Software Updated',
    'Android/iPhone மென்பொருளை எப்போதும் புதுப்பித்து வையுங்கள். Security Updates வரும்போது உடனே நிறுவுங்கள். பழைய மென்பொருளில் பாதுகாப்பு ஓட்டைகள் இருக்கும். Automatic Updates இயக்கி வையுங்கள்.',
    'Always keep Android/iPhone software updated. Install security updates as soon as they arrive. Old software has security vulnerabilities. Enable automatic updates.',
    'device',
    2
);

-- ============================================================
-- SHOPPING SAFETY (category: 'shopping')
-- ============================================================

INSERT INTO cyber_safety_tips (title_tamil, title_english, tip_tamil, tip_english, category, priority) VALUES
(
    'பாதுகாப்பான ஆன்லைன் ஷாப்பிங்',
    'Safe Online Shopping',
    'Amazon, Flipkart, Myntra போன்ற நம்பகமான தளங்களில் மட்டும் வாங்குங்கள். Instagram/Facebook விளம்பரங்களில் வரும் அறியாத கடைகளை தவிர்க்கவும். COD (Cash on Delivery) முறையில் வாங்குவது பாதுகாப்பானது. கிரெடிட் கார்டு விவரங்களை இணையதளத்தில் சேமிக்காதீர்கள்.',
    'Buy only on trusted platforms like Amazon, Flipkart, Myntra. Avoid unknown stores from Instagram/Facebook ads. Cash on Delivery (COD) is safer. Do not save credit card details on websites.',
    'shopping',
    2
),
(
    'ஆன்லைன் கட்டணப் பாதுகாப்பு',
    'Online Payment Safety',
    'கட்டணம் செலுத்தும் பக்கத்தில் https:// மற்றும் பூட்டு அடையாளம் இருப்பதை சரிபார்க்கவும். Virtual Card அல்லது UPI பயன்படுத்துவது Debit Card-ஐ விட பாதுகாப்பானது. ஆன்லைன் பரிவர்த்தனைக்கு Transaction Limit குறைவாக வையுங்கள்.',
    'Check for https:// and lock icon on payment page. Using Virtual Card or UPI is safer than debit card. Set low transaction limit for online transactions.',
    'shopping',
    2
);

-- ============================================================
-- CHILDREN'S SAFETY (category: 'children')
-- ============================================================

INSERT INTO cyber_safety_tips (title_tamil, title_english, tip_tamil, tip_english, category, priority) VALUES
(
    'குழந்தைகளின் இணைய பாதுகாப்பு',
    'Children Internet Safety',
    'குழந்தைகளின் தொலைபேசி/டேப்லெட்டில் Parental Controls இயக்கவும். Google Family Link ஆப் பயன்படுத்தவும். குழந்தைகள் யாருடன் ஆன்லைனில் பேசுகிறார்கள் என்பதை கண்காணிக்கவும். இணையத்தில் அறியாதவர்களிடம் பேசாமல் இருக்க கற்றுக்கொடுங்கள்.',
    'Enable Parental Controls on children phone/tablet. Use Google Family Link app. Monitor who children talk to online. Teach them not to talk to strangers on internet.',
    'children',
    1
),
(
    'குழந்தைகளின் ஆன்லைன் கேமிங் பாதுகாப்பு',
    'Children Online Gaming Safety',
    'குழந்தைகள் விளையாடும் ஆன்லைன் கேம்களில் In-App Purchase-ஐ முடக்கவும். Game-ல் Chat மூலம் அறியாதவர்களிடம் தனிப்பட்ட தகவல் பகிராமல் இருக்க கற்றுக்கொடுங்கள். Screen Time வரையறை அமைக்கவும்.',
    'Disable In-App Purchases in children online games. Teach children not to share personal info via game chat with strangers. Set screen time limits.',
    'children',
    2
);

-- ============================================================
-- GENERAL SAFETY (category: 'general')
-- ============================================================

INSERT INTO cyber_safety_tips (title_tamil, title_english, tip_tamil, tip_english, category, priority) VALUES
(
    'தரவு காப்புப் பிரதி (Backup) எடுங்கள்',
    'Take Regular Data Backups',
    'முக்கிய புகைப்படங்கள், ஆவணங்களை Google Drive அல்லது Google Photos-ல் காப்புப் பிரதி எடுங்கள். WhatsApp Chat Backup இயக்கவும். வாரம் ஒரு முறையாவது Backup எடுங்கள். தொலைபேசி தொலைந்தாலும் தரவு பாதுகாப்பாக இருக்கும்.',
    'Backup important photos and documents to Google Drive or Google Photos. Enable WhatsApp Chat Backup. Take backup at least once a week. Data will be safe even if phone is lost.',
    'general',
    2
),
(
    'சைபர் குற்ற புகார் செய்யும் முறை',
    'How to Report Cyber Crime',
    'சைபர் மோசடிக்கு உட்பட்டால் உடனே 1930 எண்ணில் அழைக்கவும். cybercrime.gov.in-ல் ஆன்லைனில் புகார் செய்யலாம். SMS, Call Recording, Transaction Details ஆகியவற்றை ஆதாரமாக சேமிக்கவும். அருகிலுள்ள காவல் நிலையத்திலும் புகார் செய்யவும்.',
    'If you fall victim to cyber fraud, immediately call 1930. File online complaint at cybercrime.gov.in. Save SMS, call recordings, and transaction details as evidence. Also file complaint at nearest police station.',
    'general',
    1
),
(
    'Email பாதுகாப்பு',
    'Email Safety',
    'அறியாதவர்களிடமிருந்து வரும் Email-ல் உள்ள இணைப்புகள் (Attachments) மற்றும் லிங்க்களை திறக்காதீர்கள். வங்கி, அரசு என்று கூறி வரும் Email-ன் அனுப்புநர் முகவரியை (From address) சரிபார்க்கவும். Spam/Phishing Email-ஐ Report செய்யுங்கள்.',
    'Do not open attachments and links from unknown email senders. Check the From address of emails claiming to be from banks or government. Report spam/phishing emails.',
    'general',
    2
),
(
    'SIM Lock/SIM PIN இயக்குங்கள்',
    'Enable SIM Lock/SIM PIN',
    'தொலைபேசியில் SIM Lock/SIM PIN இயக்கவும். இது SIM Swap மோசடியிலிருந்து பாதுகாக்கும். தொலைபேசி திருடப்பட்டாலும் SIM-ஐ வேறு தொலைபேசியில் பயன்படுத்த முடியாது. Settings > Security > SIM Lock-ல் இயக்கவும்.',
    'Enable SIM Lock/SIM PIN on your phone. This protects against SIM swap fraud. Even if phone is stolen, SIM cannot be used in another phone. Enable in Settings > Security > SIM Lock.',
    'general',
    2
),
(
    'ஆதார் Biometric Lock இயக்குங்கள்',
    'Enable Aadhaar Biometric Lock',
    'mAadhaar ஆப்பில் Biometric Lock இயக்குங்கள். இது உங்கள் ஆதார் Biometric-ஐ தவறாக பயன்படுத்துவதை தடுக்கும். தேவையான போது மட்டும் Unlock செய்து பயன்படுத்தவும். UIDAI இணையதளத்தில் Authentication History சரிபார்க்கவும்.',
    'Enable Biometric Lock in mAadhaar app. This prevents misuse of your Aadhaar biometrics. Unlock only when needed. Check Authentication History on UIDAI website.',
    'general',
    1
);
