-- Scam Patterns Data
-- Common scams targeting Tamil Nadu residents
-- Safety-critical data for VAZHI Tamil AI assistant

DELETE FROM scam_patterns;

-- ============================================================
-- BANKING SCAMS (type: 'banking')
-- ============================================================

INSERT INTO scam_patterns (name_tamil, name_english, type, description_tamil, description_english, red_flags_tamil, red_flags_english, example_messages, prevention_tamil, prevention_english, report_to, report_number) VALUES
(
    'போலி வங்கி SMS மோசடி',
    'Fake Bank SMS Fraud',
    'banking',
    'மோசடி செய்பவர்கள் உங்கள் வங்கிக் கணக்கு முடக்கப்படும் என்று போலி SMS அனுப்புவார்கள். அதில் உள்ள லிங்கை கிளிக் செய்தால் உங்கள் வங்கி விவரங்கள் திருடப்படும்.',
    'Fraudsters send fake SMS claiming your bank account will be blocked. Clicking the link steals your banking credentials through a phishing website.',
    'அறியாத எண்ணில் இருந்து SMS|லிங்க் கிளிக் செய்யச் சொல்வது|அவசரமாக செயல்படச் சொல்வது|வங்கி பெயர் தவறாக எழுதப்பட்டிருக்கும்|குறுகிய URL லிங்க்கள்',
    'SMS from unknown number|Asks to click a link|Creates urgency to act immediately|Bank name misspelled|Shortened URL links',
    'Dear Customer, Your SBI account will be blocked today. Update KYC immediately: http://sbi-kyc-update.xyz/verify',
    'வங்கி ஒருபோதும் SMS மூலம் KYC புதுப்பிக்கச் சொல்லாது. SMS-ல் உள்ள லிங்கை கிளிக் செய்யாதீர்கள். நேரடியாக வங்கிக் கிளைக்குச் செல்லுங்கள். சந்தேகம் இருந்தால் வங்கியின் அதிகாரப்பூர்வ எண்ணில் அழைக்கவும்.',
    'Banks never ask to update KYC via SMS. Never click links in SMS. Visit the bank branch directly. If in doubt, call the bank official number printed on your card.',
    'Cyber Crime Portal',
    '1930'
),
(
    'UPI மோசடி',
    'UPI Payment Fraud',
    'banking',
    'மோசடி செய்பவர்கள் பணம் அனுப்புவதாகக் கூறி UPI கோரிக்கை (Request) அனுப்புவார்கள். பணம் வாங்க PIN தேவையில்லை என்பதை மறந்துவிடாதீர்கள்.',
    'Scammers send UPI collect requests claiming to send you money. Remember that receiving money never requires entering your PIN.',
    'பணம் பெற PIN கேட்பது|அறியாத நபர் UPI Request அனுப்புவது|QR கோட் ஸ்கேன் செய்யச் சொல்வது|OLX/Quikr போன்ற தளங்களில் முன்பணம் கேட்பது',
    'Asking PIN to receive money|Unknown person sending UPI Request|Asking to scan QR code to receive money|Advance payment requests on OLX/Quikr',
    'I am sending Rs.5000 to your account. Please accept the UPI request and enter your PIN to receive the amount.',
    'பணம் பெற ஒருபோதும் UPI PIN தேவையில்லை. அறியாதவர்களின் UPI Request-ஐ நிராகரிக்கவும். QR கோட் ஸ்கேன் செய்வது பணம் அனுப்புவதற்கே, பெறுவதற்கு அல்ல.',
    'You never need UPI PIN to receive money. Decline UPI requests from unknown people. Scanning QR code is for sending money, not receiving it.',
    'Cyber Crime Portal / Bank',
    '1930'
),
(
    'KYC புதுப்பிப்பு மோசடி',
    'KYC Update Scam',
    'banking',
    'வங்கி KYC காலாவதி ஆகிவிட்டது, புதுப்பிக்காவிட்டால் கணக்கு முடக்கப்படும் என்று அழைத்து AnyDesk, TeamViewer போன்ற ஆப் பதிவிறக்கச் சொல்வார்கள்.',
    'Scammers call claiming bank KYC has expired and ask you to install screen sharing apps like AnyDesk or TeamViewer to steal your banking information.',
    'KYC காலாவதி என்று அழைப்பு|AnyDesk/TeamViewer நிறுவச் சொல்வது|OTP கேட்பது|உடனடி நடவடிக்கை எடுக்கச் சொல்வது',
    'Call about KYC expiry|Asks to install AnyDesk/TeamViewer|Asks for OTP|Demands immediate action',
    'This is SBI calling. Your KYC is expired. Install AnyDesk app and share the 9-digit code. We will update your KYC remotely.',
    'AnyDesk, TeamViewer போன்ற ஆப்களை ஒருபோதும் அறியாதவர் சொல்லி நிறுவாதீர்கள். KYC புதுப்பிக்க வங்கிக் கிளைக்கு நேரில் செல்லுங்கள். OTP-ஐ யாரிடமும் பகிர்ந்துகொள்ளாதீர்கள்.',
    'Never install AnyDesk, TeamViewer on stranger instructions. Visit bank branch in person for KYC update. Never share OTP with anyone.',
    'Cyber Crime Portal / Bank',
    '1930'
),
(
    'கார்டு முடக்கம் மோசடி',
    'Card Blocking Scam',
    'banking',
    'உங்கள் ATM கார்டு/கிரெடிட் கார்டு முடக்கப்படும் என்று போலி அழைப்பு வந்து, கார்டு எண், CVV, OTP ஆகியவற்றைக் கேட்பார்கள்.',
    'Scammers call claiming your ATM/credit card will be blocked and ask for card number, CVV, and OTP to steal your money.',
    'கார்டு முடக்கப்படும் என்ற அழைப்பு|கார்டு எண் முழுமையாகக் கேட்பது|CVV கேட்பது|OTP கேட்பது',
    'Call about card being blocked|Asking full card number|Asking CVV|Asking OTP',
    'Your HDFC card ending 4532 will be blocked in 2 hours. Share your full card number and CVV to prevent blocking. We will send OTP for verification.',
    'வங்கி ஊழியர்கள் ஒருபோதும் கார்டு எண், CVV, OTP கேட்கமாட்டார்கள். இது போன்ற அழைப்பு வந்தால் உடனே துண்டிக்கவும். வங்கியின் பின்புற எண்ணில் அழைத்து உறுதிப்படுத்தவும்.',
    'Bank employees never ask for card number, CVV, or OTP. Disconnect such calls immediately. Call the number on the back of your card to verify.',
    'Cyber Crime Portal / Bank',
    '1930'
),
(
    'போலி வங்கி இணையதளம்',
    'Fake Bank Website Phishing',
    'banking',
    'Google-ல் வங்கி பெயர் தேடும்போது விளம்பரமாக தோன்றும் போலி இணையதளத்தில் உள்நுழைய முயற்சித்தால் கடவுச்சொல் திருடப்படும்.',
    'Fake bank websites appear as Google ads. When you try to log in, your credentials are stolen by scammers.',
    'URL-ல் எழுத்துப் பிழை|http:// மட்டும் இருக்கும் (https:// இல்லை)|Google விளம்பரமாக வருவது|வழக்கமான தளத்திலிருந்து வேறுபட்ட வடிவமைப்பு',
    'Misspelling in URL|Only http:// instead of https://|Appears as Google ad|Different design from usual site',
    'www.sbl-onlinesbi.com (instead of www.onlinesbi.sbi.co.in)',
    'எப்போதும் வங்கி URL-ஐ நேரடியாக டைப் செய்யுங்கள். Google விளம்பரங்களை கிளிக் செய்யாதீர்கள். URL-ல் பூட்டு அடையாளம் (https) உள்ளதா சரிபார்க்கவும். வங்கியின் அதிகாரப்பூர்வ ஆப்பை பயன்படுத்துங்கள்.',
    'Always type bank URL directly. Do not click Google ads. Check for lock icon (https) in URL. Use the official bank app.',
    'Cyber Crime Portal',
    '1930'
);

-- ============================================================
-- PHONE SCAMS (type: 'phone')
-- ============================================================

INSERT INTO scam_patterns (name_tamil, name_english, type, description_tamil, description_english, red_flags_tamil, red_flags_english, example_messages, prevention_tamil, prevention_english, report_to, report_number) VALUES
(
    'போலி சுங்க அதிகாரி அழைப்பு',
    'Fake Customs Officer Call',
    'phone',
    'சுங்கத்துறை/நார்கோடிக்ஸ் அதிகாரி என்று அழைத்து, உங்கள் பெயரில் போதைப்பொருள் பார்சல் வந்துள்ளது, கைது ஆவீர்கள் என்று பயமுறுத்தி பணம் கேட்பார்கள்.',
    'Scammers pose as customs/narcotics officers claiming a drug parcel has arrived in your name, threaten arrest, and demand money to settle the case.',
    'சுங்கத்துறை/போலீஸ் என்று அழைப்பு|கைது வாரண்ட் என்று மிரட்டல்|போதைப்பொருள் பார்சல் என்று கூறுவது|NEFT/UPI மூலம் பணம் கேட்பது|Skype/WhatsApp வீடியோ கால் செய்யச் சொல்வது',
    'Call from customs/police|Threatening arrest warrant|Claiming drug parcel|Asking money via NEFT/UPI|Asking to join Skype/WhatsApp video call',
    'This is Mumbai Customs. A parcel with drugs addressed to your Aadhaar number has been intercepted. FIR will be filed. Transfer Rs.50,000 as security deposit to avoid arrest.',
    'அரசு அதிகாரிகள் ஒருபோதும் தொலைபேசியில் பணம் கேட்கமாட்டார்கள். பயமுறுத்தும் அழைப்புகளை துண்டிக்கவும். நம்பகமான நபரிடம் ஆலோசிக்கவும். 1930-ல் புகார் செய்யவும்.',
    'Government officials never ask for money over phone. Disconnect threatening calls. Consult a trusted person. Report to 1930.',
    'Cyber Crime Portal / Police',
    '1930'
),
(
    'போலி காப்பீடு மோசடி',
    'Insurance Scam',
    'phone',
    'காப்பீட்டு நிறுவனம் என்று அழைத்து போனஸ் அல்லது முதிர்வுத் தொகை வழங்குவதாகக் கூறி, வரி/செயலாக்கக் கட்டணம் என்று பணம் கேட்பார்கள்.',
    'Scammers pose as insurance companies offering bonus or maturity amount and demand processing fees or taxes before releasing the payment.',
    'எதிர்பாராத போனஸ் தொகை|செயலாக்கக் கட்டணம் கேட்பது|வங்கி விவரங்கள் கேட்பது|உடனடி நடவடிக்கை கேட்பது',
    'Unexpected bonus amount|Asking processing fees|Requesting bank details|Demanding immediate action',
    'Congratulations! Your LIC policy bonus of Rs.2,75,000 is ready. Pay Rs.8,500 processing fee via Google Pay to 9876543210 to claim your amount today.',
    'காப்பீடு நிறுவனங்கள் போனஸ் வழங்க முன்கூட்டியே பணம் கேட்காது. LIC கிளை அலுவலகத்தில் நேரில் விசாரிக்கவும். Google Pay/PhonePe மூலம் கட்டணம் செலுத்த வேண்டாம்.',
    'Insurance companies never ask for advance payment to release bonus. Verify at LIC branch office in person. Do not pay fees via Google Pay/PhonePe.',
    'Cyber Crime Portal / IRDAI',
    '1930'
),
(
    'லாட்டரி மோசடி',
    'Lottery Scam',
    'phone',
    'KBC, Jio, Airtel போன்ற நிறுவனங்கள் பெயரில் லாட்டரி வென்றுள்ளீர்கள் என்று அழைத்து, வரி/பதிவுக் கட்டணம் செலுத்தச் சொல்வார்கள்.',
    'Scammers claim you have won a lottery from KBC, Jio, or Airtel and ask you to pay tax or registration fees to claim the prize.',
    'விண்ணப்பிக்காத லாட்டரி|வரி கட்டணம் முன்கூட்டியே கேட்பது|WhatsApp மூலம் லாட்டரி அறிவிப்பு|இந்திய அரசு லோகோ பயன்பாடு',
    'Lottery you never entered|Asking tax payment in advance|Lottery notification via WhatsApp|Using Indian government logo',
    'Congratulations! Your mobile number has won Rs.25,00,000 in KBC Lucky Draw. Contact manager at 9988776655. Pay Rs.12,000 tax to claim.',
    'விண்ணப்பிக்காத லாட்டரி வெல்ல முடியாது. KBC ஒருபோதும் தொலைபேசியில் லாட்டரி அறிவிக்காது. முன்கூட்டியே எந்த கட்டணமும் செலுத்தாதீர்கள்.',
    'You cannot win a lottery you never entered. KBC never announces lottery by phone. Never pay any advance fees.',
    'Cyber Crime Portal',
    '1930'
),
(
    'போலி போலீஸ் அழைப்பு',
    'Police Impersonation Scam',
    'phone',
    'போலீஸ் அதிகாரி என்று அழைத்து, உங்கள் ஆதார்/பான் தவறாக பயன்படுத்தப்பட்டுள்ளது, டிஜிட்டல் கைது (Digital Arrest) செய்யப்படுவீர்கள் என்று மிரட்டி பணம் கேட்பார்கள்.',
    'Scammers impersonate police officers, claim your Aadhaar/PAN has been misused, threaten digital arrest, and extort money.',
    'டிஜிட்டல் கைது என்ற வார்த்தை|Skype/WhatsApp வீடியோவில் போலீஸ் சீருடை|வீட்டை விட்டு வெளியே போகாதீர்கள் என்று கட்டளை|பணம் RBI கணக்குக்கு மாற்றச் சொல்வது',
    'Term "Digital Arrest"|Police uniform on Skype/WhatsApp video|Ordering not to leave house|Asking to transfer money to RBI account',
    'This is CBI Officer Sharma. Your Aadhaar is linked to money laundering case. You are under Digital Arrest. Transfer funds to RBI verification account or face imprisonment.',
    'டிஜிட்டல் கைது என்பது சட்டத்தில் இல்லை. போலீஸ் ஒருபோதும் தொலைபேசியில் கைது செய்யாது. பணம் RBI கணக்குக்கு மாற்றச் சொல்வது மோசடி. உடனே 1930-ல் புகார் செய்யவும்.',
    'Digital Arrest does not exist in law. Police never arrest over phone. Asking to transfer money to RBI account is fraud. Report to 1930 immediately.',
    'Cyber Crime Portal / Police',
    '1930'
),
(
    'கூரியர் டெலிவரி மோசடி',
    'Courier Delivery Scam',
    'phone',
    'FedEx/DHL என்று அழைத்து, உங்கள் பார்சல் சுங்கத்தில் நிறுத்தப்பட்டுள்ளது, சுங்கவரி செலுத்தினால் விடுவிக்கப்படும் என்று கூறி பணம் கேட்பார்கள்.',
    'Scammers pose as FedEx/DHL claiming your parcel is held at customs and demand customs duty payment to release it.',
    'எதிர்பாராத பார்சல் அறிவிப்பு|சுங்கவரி செலுத்தச் சொல்வது|UPI/NEFT மூலம் பணம் கேட்பது|போலீஸ் அதிகாரிக்கு அழைப்பை மாற்றுவது',
    'Unexpected parcel notification|Asking to pay customs duty|Requesting money via UPI/NEFT|Transferring call to police officer',
    'FedEx calling. A parcel from Thailand in your name contains illegal items. Pay Rs.35,000 customs duty or the matter will be forwarded to police.',
    'கூரியர் நிறுவனங்கள் ஒருபோதும் தொலைபேசியில் சுங்கவரி கேட்காது. யாரும் பார்சல் அனுப்பியுள்ளார்களா என்று சரிபார்க்கவும். இதுபோன்ற அழைப்புகளை உடனே துண்டிக்கவும்.',
    'Courier companies never ask customs duty over phone. Verify if someone actually sent you a parcel. Disconnect such calls immediately.',
    'Cyber Crime Portal',
    '1930'
),
(
    'எலக்ட்ரிசிட்டி பில் மோசடி',
    'Electricity Bill Disconnection Scam',
    'phone',
    'TNEB (தமிழ்நாடு மின்சார வாரியம்) என்று அழைத்து அல்லது SMS அனுப்பி, மின்சாரம் இன்று துண்டிக்கப்படும் என்று கூறி UPI மூலம் பணம் கேட்பார்கள்.',
    'Scammers pose as TNEB (Tamil Nadu Electricity Board) via call or SMS threatening disconnection today unless immediate payment is made via UPI.',
    'இன்றே துண்டிக்கப்படும் என்று அச்சுறுத்தல்|UPI/Google Pay மூலம் பணம் கேட்பது|TNEB எண் அல்லாத எண்ணிலிருந்து அழைப்பு|ஆப் மூலம் பணம் செலுத்தச் சொல்வது',
    'Threatening disconnection today|Asking money via UPI/Google Pay|Call from non-TNEB number|Asking to pay through app',
    'TNEB Alert: Your electricity connection will be disconnected today due to pending bill of Rs.3,456. Pay immediately via Google Pay to 8877665544 to avoid disconnection.',
    'TNEB அதிகாரப்பூர்வ இணையதளம் அல்லது TNEB ஆப் மூலமே பில் செலுத்துங்கள். தனிநபர் UPI-க்கு பணம் அனுப்பாதீர்கள். சந்தேகம் இருந்தால் TNEB எண் 94987-94987 அழைக்கவும்.',
    'Pay bills only through TNEB official website or TNEB app. Do not send money to personal UPI. If in doubt, call TNEB helpline 94987-94987.',
    'Cyber Crime Portal / TNEB',
    '1930'
);

-- ============================================================
-- DIGITAL SCAMS (type: 'digital')
-- ============================================================

INSERT INTO scam_patterns (name_tamil, name_english, type, description_tamil, description_english, red_flags_tamil, red_flags_english, example_messages, prevention_tamil, prevention_english, report_to, report_number) VALUES
(
    'WhatsApp ஃபார்வர்டிங் மோசடி',
    'WhatsApp Forwarding Scam',
    'digital',
    'WhatsApp-ல் "இந்த மெசேஜை 10 பேருக்கு அனுப்பினால் ரூ.500 பரிசு" என்ற போலி செய்திகள் பரவுகின்றன. லிங்கை கிளிக் செய்தால் தகவல் திருடப்படும்.',
    'Fake WhatsApp messages claim you will get prizes for forwarding messages to 10 people. Clicking the link steals your personal information.',
    'ஃபார்வர்ட் செய்தால் பரிசு|அதிகமாக ஃபார்வர்ட் செய்யப்பட்ட செய்தி|சந்தேகத்திற்குரிய லிங்க்|இலவச ரீசார்ஜ் வாக்குறுதி',
    'Prize for forwarding|Heavily forwarded message|Suspicious link|Free recharge promise',
    'Jio is giving FREE 50GB data! Forward this message to 10 friends and get instant recharge: http://jio-free-data.win',
    'WhatsApp-ல் வரும் சந்தேகத்திற்குரிய லிங்க்களை கிளிக் செய்யாதீர்கள். ஃபார்வர்ட் செய்யப்பட்ட செய்திகளை நம்பாதீர்கள். அதிகாரப்பூர்வ இணையதளங்களில் மட்டுமே சலுகைகளை சரிபார்க்கவும்.',
    'Do not click suspicious links on WhatsApp. Do not trust forwarded messages. Verify offers only on official websites.',
    'Cyber Crime Portal',
    '1930'
),
(
    'போலி வேலை வாய்ப்பு மோசடி',
    'Fake Job Offer Scam',
    'digital',
    'வீட்டிலிருந்தே வேலை, தினமும் ரூ.5000 சம்பாதிக்கலாம் என்று போலி வேலை வாய்ப்பு SMS/WhatsApp-ல் வரும். பதிவுக் கட்டணம் அல்லது பயிற்சிக் கட்டணம் என்று பணம் கேட்பார்கள்.',
    'Fake job offers promising work from home and Rs.5000/day income sent via SMS/WhatsApp. They demand registration or training fees upfront.',
    'அதிக சம்பளம் வாக்குறுதி|பதிவுக் கட்டணம் கேட்பது|WhatsApp/Telegram மூலம் வேலை வாய்ப்பு|நிறுவன விவரம் இல்லாமை|தினமும் கட்டாயம் வேலை செய்ய வேண்டும் என்ற நிபந்தனை',
    'Unrealistic salary promise|Asking registration fee|Job offer via WhatsApp/Telegram|No company details|Mandatory daily task condition',
    'Amazon is hiring! Work from home, earn Rs.5000-15000 daily. No experience needed. WhatsApp us at 9123456789. Limited seats. Registration fee Rs.500 only.',
    'நம்பகமான நிறுவனங்கள் பதிவுக் கட்டணம் கேட்காது. WhatsApp/Telegram மூலம் வரும் வேலை வாய்ப்புகளை நம்பாதீர்கள். நிறுவனத்தின் அதிகாரப்பூர்வ இணையதளத்தில் சரிபார்க்கவும்.',
    'Genuine companies never ask registration fees. Do not trust job offers via WhatsApp/Telegram. Verify on company official website.',
    'Cyber Crime Portal',
    '1930'
),
(
    'காதல் மோசடி',
    'Romance Scam',
    'digital',
    'சமூக ஊடகங்களில் போலி சுயவிவரத்தில் நட்பு கொண்டு, நம்பிக்கை வளர்த்து, பின்னர் மருத்துவச் செலவு, விமான டிக்கெட் என்று பணம் கேட்பார்கள்.',
    'Scammers create fake profiles on social media, build trust over weeks/months, then ask for money citing medical expenses, flight tickets, or emergencies.',
    'சமூக ஊடகத்தில் திடீர் நட்பு|வீடியோ கால் தவிர்ப்பது|பரிதாபக் கதை சொல்வது|பணம் கேட்பது|வெளிநாட்டு ராணுவ/எண்ணெய் நிறுவன ஊழியர் என்று கூறுவது',
    'Sudden friendship on social media|Avoiding video calls|Sob stories|Asking for money|Claiming to be foreign military/oil company employee',
    'Hi dear, I am David from US Army stationed in Syria. I love you. I need Rs.50,000 urgently for medical treatment. I will repay when I visit India.',
    'சமூக ஊடகங்களில் அறியாதவர்களை நம்பாதீர்கள். நேரில் சந்திக்காத நபருக்கு பணம் அனுப்பாதீர்கள். அவர்களின் புகைப்படத்தை Google-ல் தேடி சரிபார்க்கவும்.',
    'Do not trust strangers on social media. Never send money to someone you have not met in person. Reverse image search their photos on Google.',
    'Cyber Crime Portal',
    '1930'
),
(
    'கிரிப்டோ முதலீடு மோசடி',
    'Crypto Investment Scam',
    'digital',
    'சமூக ஊடகங்களில் கிரிப்டோ/பிட்காயின் மூலம் குறுகிய காலத்தில் அதிக லாபம் கிடைக்கும் என்று போலி விளம்பரங்கள் வரும். முதலீடு செய்தால் பணம் இழப்பீர்கள்.',
    'Fake ads on social media promising high returns through crypto/Bitcoin in short time. Investing leads to complete loss of money.',
    'குறுகிய காலத்தில் அதிக லாபம்|100% வருமானம் உத்தரவாதம்|அறியாத ஆப்/இணையதளம்|பிரபலங்களின் போலி பரிந்துரை|Telegram குழுவில் "சிக்னல்" தருவதாக கூறுவது',
    'High returns in short time|100% return guaranteed|Unknown app/website|Fake celebrity endorsement|Claiming to give "signals" in Telegram group',
    'Elon Musk recommended Bitcoin! Invest Rs.10,000 today and get Rs.1,00,000 in 30 days. Join our VIP Telegram group for trading signals.',
    'யாரும் லாபத்தை உத்தரவாதம் செய்ய முடியாது. பிரபலங்களின் பரிந்துரை பெரும்பாலும் போலியானவை. SEBI பதிவு செய்யப்பட்ட தளங்களில் மட்டும் முதலீடு செய்யுங்கள்.',
    'Nobody can guarantee profits. Celebrity endorsements are mostly fake. Invest only on SEBI registered platforms.',
    'Cyber Crime Portal / SEBI',
    '1930'
),
(
    'போலி ஆப் மோசடி',
    'Fake App Scam',
    'digital',
    'போலி கடன் ஆப்கள், போலி ஷாப்பிங் ஆப்கள் Google Play Store-ல் உள்ளன. இவற்றை பதிவிறக்கினால் தனிப்பட்ட தகவல்கள் திருடப்படும் அல்லது அதிக வட்டி வசூலிக்கப்படும்.',
    'Fake loan apps and fake shopping apps exist on Google Play Store. Downloading them leads to personal data theft or extortion with high interest rates.',
    'அதிகமான permissions கேட்பது|மிகக் குறைந்த ratings|புதிய டெவலப்பர்|கடன் ஆப் Contacts/Gallery அணுகல் கேட்பது|மிகவும் எளிய கடன் வாக்குறுதி',
    'Excessive permissions requested|Very low ratings|New developer|Loan app asking Contacts/Gallery access|Very easy loan promise',
    'Instant Loan Rs.50,000 in 5 minutes! No documents needed! Download our app now.',
    'அறியாத ஆப்களை பதிவிறக்காதீர்கள். Play Store ratings மற்றும் reviews படிக்கவும். கடன் ஆப்கள் RBI பதிவு செய்யப்பட்டதா சரிபார்க்கவும். தேவையற்ற permissions கொடுக்காதீர்கள்.',
    'Do not download unknown apps. Read Play Store ratings and reviews. Verify if loan apps are RBI registered. Do not grant unnecessary permissions.',
    'Cyber Crime Portal / RBI',
    '1930'
),
(
    'சமூக ஊடக ஹேக்கிங் மோசடி',
    'Social Media Hacking Scam',
    'digital',
    'நண்பரின் ஹேக் செய்யப்பட்ட கணக்கிலிருந்து அவசர பணத் தேவை என்று செய்தி வரும். அல்லது உங்கள் Instagram/Facebook கணக்கை ஹேக் செய்து மீட்க பணம் கேட்பார்கள்.',
    'Messages from hacked friend accounts asking for urgent money. Or scammers hack your Instagram/Facebook and demand payment to restore access.',
    'நண்பர் திடீரென பணம் கேட்பது|வழக்கமான பேச்சு நடையில்லாமை|Google Play கார்டு வாங்கச் சொல்வது|கணக்கு மீட்க பணம் கேட்பது',
    'Friend suddenly asking for money|Unusual communication style|Asking to buy Google Play cards|Demanding money to restore account',
    'Hey! Its me. Im stuck at hospital. Can you urgently send Rs.5000 to this GPay number 9876543210? Will return tomorrow.',
    'நண்பர் பணம் கேட்டால் தொலைபேசியில் நேரடியாக அழைத்து உறுதிப்படுத்தவும். Google Play கார்டு அல்லது Gift கார்டு வாங்கச் சொன்னால் மோசடி. 2FA இயக்கி கணக்கைப் பாதுகாக்கவும்.',
    'If a friend asks for money, call them directly on phone to verify. Requests for Google Play or Gift cards are scams. Enable 2FA to protect your accounts.',
    'Cyber Crime Portal',
    '1930'
),
(
    'Telegram பணம் சம்பாதிக்கும் மோசடி',
    'Telegram Task Fraud',
    'digital',
    'Telegram-ல் YouTube வீடியோவிற்கு Like போடுங்கள், Google Maps-ல் Review எழுதுங்கள் என்று சொல்லி ஆரம்பத்தில் சிறிய தொகை தருவார்கள். பின்னர் பெரிய தொகை முதலீடு செய்யச் சொல்வார்கள்.',
    'Telegram groups offer small payments for liking YouTube videos or writing Google Maps reviews. After initial small payments, they demand large investment amounts.',
    'ஆரம்பத்தில் சிறிய பணம் தருவது|பின்னர் முதலீடு கேட்பது|VIP Task என்று அதிக பணம் வாக்குறுதி|Telegram குழுவில் போலி வெற்றிக் கதைகள்|பணம் திரும்ப வராது',
    'Small initial payments|Later demanding investment|VIP Task with higher earnings promise|Fake success stories in Telegram group|Money not refundable',
    'Join our Telegram channel. Like YouTube videos and earn Rs.50 per like. Upgrade to VIP (Rs.5,000) and earn Rs.500 per task. Daily income Rs.10,000+',
    'ஆரம்பத்தில் பணம் தந்தாலும் இது மோசடி திட்டம். முதலீடு கேட்கும்போது அனைத்தையும் இழப்பீர்கள். எந்த தளத்திலும் Task செய்து பணம் சம்பாதிக்கலாம் என்று நம்பாதீர்கள்.',
    'Even if they pay initially, this is a scam scheme. You will lose everything when they ask for investment. Do not believe earn-by-doing-tasks schemes.',
    'Cyber Crime Portal',
    '1930'
);

-- ============================================================
-- GOVERNMENT SCAMS (type: 'government')
-- ============================================================

INSERT INTO scam_patterns (name_tamil, name_english, type, description_tamil, description_english, red_flags_tamil, red_flags_english, example_messages, prevention_tamil, prevention_english, report_to, report_number) VALUES
(
    'போலி அரசு திட்ட பதிவு மோசடி',
    'Fake Government Scheme Registration Scam',
    'government',
    'PM கிசான், இலவச ரேஷன் கார்டு, வீடு கட்ட மானியம் போன்ற போலி அரசு திட்டங்களுக்கு பதிவு செய்ய கட்டணம் கேட்பார்கள்.',
    'Scammers demand registration fees for fake government schemes like PM Kisan, free ration card, or housing subsidies.',
    'அரசு திட்டத்திற்கு பதிவுக் கட்டணம்|WhatsApp மூலம் விண்ணப்பம்|தனிநபர் கணக்குக்கு பணம் கேட்பது|போலி அரசு இணையதளம்',
    'Registration fee for govt scheme|Application via WhatsApp|Money to personal account|Fake government website',
    'PM Awas Yojana: Get Rs.2,50,000 for house construction. Register now by paying Rs.1,500 processing fee. Send to UPI: govtscheme@paytm',
    'அரசு திட்டங்களுக்கு பதிவுக் கட்டணம் இல்லை. அரசு திட்டங்கள் gov.in இணையதளத்தில் மட்டுமே. அருகிலுள்ள e-Sevai மையத்தில் விசாரிக்கவும்.',
    'Government schemes have no registration fees. Government schemes are only on gov.in websites. Enquire at nearest e-Sevai center.',
    'Cyber Crime Portal / Police',
    '1930'
),
(
    'ஆதார் புதுப்பிப்பு மோசடி',
    'Aadhaar Update Scam',
    'government',
    'ஆதார் காலாவதி ஆகிவிட்டது, புதுப்பிக்காவிட்டால் SIM, வங்கி கணக்கு முடக்கப்படும் என்று அழைத்து ஆதார் எண், OTP கேட்பார்கள்.',
    'Scammers call claiming Aadhaar has expired and SIM/bank account will be blocked unless updated, then ask for Aadhaar number and OTP.',
    'ஆதார் காலாவதி என்று அழைப்பு|ஆதார் எண் கேட்பது|OTP பகிரச் சொல்வது|ஆப் நிறுவச் சொல்வது',
    'Call about Aadhaar expiry|Asking Aadhaar number|Asking to share OTP|Asking to install app',
    'UIDAI Alert: Your Aadhaar card will be deactivated in 24 hours. Call 8899776655 immediately to update your Aadhaar details.',
    'ஆதார் காலாவதி ஆகாது. UIDAI ஒருபோதும் தொலைபேசியில் ஆதார் விவரம் கேட்காது. ஆதார் புதுப்பிக்க uidai.gov.in அல்லது ஆதார் மையத்திற்கு செல்லவும். OTP-ஐ யாரிடமும் பகிர வேண்டாம்.',
    'Aadhaar never expires. UIDAI never asks Aadhaar details by phone. Update Aadhaar at uidai.gov.in or Aadhaar center. Never share OTP.',
    'Cyber Crime Portal / UIDAI',
    '1930'
),
(
    'போலி e-Sevai மோசடி',
    'Fake e-Sevai Scam',
    'government',
    'போலி e-Sevai மையங்கள் அதிகக் கட்டணம் வசூலிப்பது அல்லது தவறான விண்ணப்பங்கள் சமர்ப்பித்து பணம் பறிப்பது.',
    'Fake e-Sevai centers charge excessive fees or submit incorrect applications to defraud applicants.',
    'அதிகக் கட்டணம் வசூலிப்பது|ரசீது தராமை|அரசு அலுவலகத்திற்கு வெளியே இயங்குவது|ஆன்லைனில் விண்ணப்பிக்க முடியாது என்று கூறுவது',
    'Charging excessive fees|Not providing receipt|Operating outside govt office|Claiming online application is not possible',
    NULL,
    'அரசு e-Sevai மையங்கள் மட்டுமே அங்கீகரிக்கப்பட்டவை. கட்டணப் பட்டியலை சரிபார்க்கவும். ரசீது வாங்கவும். tnedistrict.tn.gov.in-ல் நேரடியாக விண்ணப்பிக்கலாம்.',
    'Only authorized govt e-Sevai centers are legitimate. Verify fee chart. Get receipt. Apply directly at tnedistrict.tn.gov.in.',
    'District Collector Office',
    '100'
),
(
    'போலி வரி திரும்பப்பெறுதல் மோசடி',
    'Fake Tax Refund Scam',
    'government',
    'வருமான வரித்துறை என்று அழைத்து வரி திரும்பப்பெறுதல் (Tax Refund) நிலுவையில் உள்ளது, வங்கி விவரங்கள் தரவும் என்று கேட்பார்கள்.',
    'Scammers pose as Income Tax Department claiming tax refund is pending and ask for bank details to process it.',
    'எதிர்பாராத வரி திரும்பப்பெறுதல்|வங்கி விவரங்கள் கேட்பது|SMS-ல் வரும் போலி லிங்க்|உடனடி நடவடிக்கை கேட்பது',
    'Unexpected tax refund|Asking bank details|Fake link in SMS|Demanding immediate action',
    'Income Tax Department: Your refund of Rs.15,432 is pending. Click http://it-refund-claim.xyz to submit your bank details for processing.',
    'வருமான வரித்துறை ஒருபோதும் SMS/Email மூலம் வங்கி விவரங்கள் கேட்காது. incometax.gov.in-ல் மட்டும் சரிபார்க்கவும். லிங்க்களை கிளிக் செய்யாதீர்கள்.',
    'Income Tax Department never asks bank details via SMS/Email. Check only at incometax.gov.in. Do not click links.',
    'Cyber Crime Portal / Income Tax',
    '1930'
),
(
    'போலி PM-KISAN மோசடி',
    'Fake PM-KISAN Scam',
    'government',
    'PM-KISAN தொகை வரவில்லை என்று விவசாயிகளிடம் அழைத்து, e-KYC செய்ய ஆதார், வங்கி விவரங்கள் கேட்பார்கள்.',
    'Scammers call farmers claiming PM-KISAN amount has not been credited and ask for Aadhaar and bank details for e-KYC verification.',
    'PM-KISAN தொகை நிலுவை என்று அழைப்பு|ஆதார், வங்கி விவரம் கேட்பது|ஆப் நிறுவச் சொல்வது|கட்டணம் கேட்பது',
    'Call about PM-KISAN pending|Asking Aadhaar and bank details|Asking to install app|Demanding fee',
    'PM-KISAN e-KYC failed. Your Rs.6,000 is held. Share Aadhaar and bank passbook photo on WhatsApp 9876543210 for immediate processing.',
    'PM-KISAN e-KYC-ஐ pmkisan.gov.in-ல் மட்டுமே செய்யவும். WhatsApp-ல் ஆதார், வங்கி விவரம் அனுப்ப வேண்டாம். அருகிலுள்ள வேளாண்மை அலுவலகத்தில் விசாரிக்கவும்.',
    'Do PM-KISAN e-KYC only at pmkisan.gov.in. Do not send Aadhaar, bank details on WhatsApp. Enquire at nearest agriculture office.',
    'Cyber Crime Portal / Agriculture Dept',
    '1930'
);

-- ============================================================
-- SHOPPING SCAMS (type: 'shopping')
-- ============================================================

INSERT INTO scam_patterns (name_tamil, name_english, type, description_tamil, description_english, red_flags_tamil, red_flags_english, example_messages, prevention_tamil, prevention_english, report_to, report_number) VALUES
(
    'போலி ஆன்லைன் கடை மோசடி',
    'Fake Online Store Scam',
    'shopping',
    'Instagram/Facebook விளம்பரங்களில் மிகக் குறைந்த விலையில் பிராண்ட் பொருட்கள் விற்பதாகக் கூறி, பணம் வாங்கிவிட்டு பொருளை அனுப்பாத மோசடி.',
    'Fake online stores advertised on Instagram/Facebook sell branded products at very low prices, take payment, and never deliver the product.',
    'மிகக் குறைந்த விலை|Instagram/Facebook விளம்பரம்|பணம் முன்கூட்டியே கேட்பது|Customer care எண் இல்லை|போலி website (.xyz, .shop)|COD வசதி இல்லை',
    'Very low price|Instagram/Facebook ad|Advance payment required|No customer care number|Fake website (.xyz, .shop)|No COD option',
    'iPhone 15 Pro Max at Rs.12,999 only! Limited stock! Order now at www.apple-india-deals.shop. Pay via Google Pay for instant delivery.',
    'மிகக் குறைந்த விலையில் பிராண்ட் பொருட்கள் விற்றால் மோசடி. Amazon, Flipkart போன்ற நம்பகமான தளங்களில் மட்டும் வாங்குங்கள். COD முறையில் வாங்குவது பாதுகாப்பானது.',
    'Branded products at very low prices are scams. Buy only on trusted platforms like Amazon, Flipkart. Cash on Delivery is safer.',
    'Cyber Crime Portal / Consumer Forum',
    '1930'
),
(
    'COD மோசடி',
    'Cash on Delivery Scam',
    'shopping',
    'COD ஆர்டர் என்று போலி பார்சல் கொண்டுவந்து, பணம் வாங்கிவிட்டு உள்ளே வேறு பொருள் அல்லது காலி பெட்டி இருக்கும்.',
    'Scammers deliver fake COD parcels, collect payment, and the package contains wrong items or is empty.',
    'ஆர்டர் செய்யாத பார்சல்|டெலிவரி நபர் அவசரப்படுத்துவது|பார்சலை திறக்க அனுமதிக்காமை|பெயர்/முகவரி சரியாக இருப்பது ஆனால் ஆர்டர் செய்யவில்லை',
    'Parcel not ordered|Delivery person rushing|Not allowing to open parcel|Name/address correct but not ordered',
    NULL,
    'ஆர்டர் செய்யாத பார்சலை ஏற்காதீர்கள். பணம் செலுத்தும் முன் பார்சலை திறந்து சரிபார்க்கவும். Amazon/Flipkart ஆப்பில் ஆர்டர் இருக்கிறதா சரிபார்க்கவும்.',
    'Do not accept parcels you did not order. Open and verify parcel before paying. Check if order exists in Amazon/Flipkart app.',
    'Consumer Forum / Police',
    '100'
),
(
    'போலி தயாரிப்பு விமர்சன மோசடி',
    'Fake Product Review Scam',
    'shopping',
    'போலி 5-star reviews போட்டு தரம் குறைந்த பொருட்களை விற்கும் மோசடி. Amazon/Flipkart-ல் கூட போலி விமர்சனங்கள் இருக்கும்.',
    'Fake 5-star reviews used to sell low quality products. Even Amazon/Flipkart have fake reviews.',
    'அனைத்தும் 5-star reviews|ஒரே மாதிரியான review மொழி|Reviewer-க்கு ஒரே ஒரு review|விரிவான review இல்லாமை|review-ல் புகைப்படம் இல்லை',
    'All 5-star reviews|Similar review language|Reviewer has only one review|No detailed reviews|No photos in reviews',
    NULL,
    'Reviews-ஐ கவனமாக படிக்கவும். 3-star மற்றும் 1-star reviews-ஐ முதலில் படிக்கவும். Verified Purchase tag உள்ள reviews-ஐ நம்பவும். பல தளங்களில் ஒப்பிட்டுப் பாருங்கள்.',
    'Read reviews carefully. Read 3-star and 1-star reviews first. Trust reviews with Verified Purchase tag. Compare across multiple platforms.',
    'Consumer Forum',
    '1800-11-4000'
),
(
    'OLX/Quikr மோசடி',
    'OLX/Quikr Classified Scam',
    'shopping',
    'OLX/Quikr-ல் குறைந்த விலையில் பொருள் விற்பதாகக் கூறி, Token Amount அல்லது Transport Charges என்று பணம் கேட்பார்கள். ராணுவ வீரர் என்று நம்பவைப்பார்கள்.',
    'Scammers on OLX/Quikr sell items at low prices, demand token amount or transport charges. Often impersonate army personnel for credibility.',
    'மிகக் குறைந்த விலை|ராணுவ வீரர் என்று கூறுவது|Token Amount கேட்பது|Transport Charges கேட்பது|பொருளை பார்க்க அனுமதிக்காமை',
    'Very low price|Claiming to be army personnel|Asking token amount|Asking transport charges|Not allowing to see the item',
    'I am Major Sharma, posted in Kashmir. Selling my Royal Enfield for Rs.30,000 due to transfer. Pay Rs.5,000 transport charge to receive the bike.',
    'பொருளை நேரில் பார்க்காமல் பணம் அனுப்ப வேண்டாம். Token Amount கேட்டால் மோசடி. ராணுவ வீரர் கதையை நம்ப வேண்டாம். நேரில் சந்தித்து பொருளை சரிபார்த்த பின் பணம் செலுத்துங்கள்.',
    'Do not send money without seeing the item in person. Token amount requests are scams. Do not believe army officer stories. Meet in person, verify item, then pay.',
    'Cyber Crime Portal',
    '1930'
);

-- ============================================================
-- INVESTMENT SCAMS (type: 'investment')
-- ============================================================

INSERT INTO scam_patterns (name_tamil, name_english, type, description_tamil, description_english, red_flags_tamil, red_flags_english, example_messages, prevention_tamil, prevention_english, report_to, report_number) VALUES
(
    'சிட் ஃபண்ட் மோசடி',
    'Chit Fund Fraud',
    'investment',
    'பதிவு செய்யப்படாத சிட் ஃபண்ட் நிறுவனங்கள் அதிக வட்டி வாக்குறுதி செய்து பணம் திரட்டி ஏமாற்றுவது. தமிழ்நாட்டில் இது மிகவும் பரவலானது.',
    'Unregistered chit fund companies collect money promising high returns and eventually disappear. This is very common in Tamil Nadu.',
    'அதிக வட்டி வாக்குறுதி (மாதம் 5-10%)|பதிவு சான்றிதழ் இல்லை|அதிகாரப்பூர்வ ரசீது இல்லை|முகவர் மூலம் சேகரிப்பு|வெளிப்படையான கணக்கு இல்லை',
    'High interest promise (5-10% monthly)|No registration certificate|No official receipt|Collection through agents|No transparent accounting',
    NULL,
    'SEBI/RBI பதிவு செய்யப்பட்ட நிறுவனங்களில் மட்டும் முதலீடு செய்யுங்கள். மாதம் 5% வட்டி என்பது மோசடி. அதிகாரப்பூர்வ ரசீது இல்லாமல் பணம் தர வேண்டாம். காவல் நிலையத்தில் புகார் செய்யுங்கள்.',
    'Invest only in SEBI/RBI registered companies. 5% monthly interest is a scam. Do not pay without official receipt. File complaint at police station.',
    'Police / Economic Offences Wing',
    '100'
),
(
    'பான்சி திட்ட மோசடி',
    'Ponzi Scheme Fraud',
    'investment',
    'பழைய முதலீட்டாளர்களுக்கு புதிய முதலீட்டாளர்களின் பணத்தை வட்டியாக கொடுத்து நம்பவைக்கும் மோசடி. கடைசியில் அனைவரும் பணம் இழப்பார்கள்.',
    'Ponzi schemes pay old investors using new investor money to build trust. Eventually all investors lose their money when the scheme collapses.',
    'உறுதியான அதிக வருமானம்|நண்பர்களை சேர்த்தால் கூடுதல் வருமானம்|MLM போன்ற அமைப்பு|பணம் எடுக்க சிரமம்|கட்டணம் செலுத்தி உறுப்பினர் ஆகவும் என்று கேட்பது',
    'Guaranteed high returns|Extra income for adding friends|MLM-like structure|Difficulty withdrawing money|Pay to become member',
    'Join our investment club! Invest Rs.10,000 and get Rs.15,000 in 3 months. Refer 3 friends and earn Rs.3,000 bonus per referral. Guaranteed returns!',
    'உறுதியான வருமானம் என்பது மோசடியின் அடையாளம். நண்பர்களை சேர்க்கச் சொல்வது MLM/Ponzi. SEBI-யில் பதிவு செய்யப்பட்ட Mutual Fund-களில் முதலீடு செய்யுங்கள்.',
    'Guaranteed returns is a sign of fraud. Asking to add friends is MLM/Ponzi. Invest in SEBI registered Mutual Funds.',
    'Police / SEBI',
    '100'
),
(
    'Forex Trading மோசடி',
    'Forex Trading Scam',
    'investment',
    'Forex/Binary Options மூலம் குறுகிய காலத்தில் அதிக லாபம் என்று போலி ஆப்/இணையதளத்தில் முதலீடு செய்யச் சொல்வார்கள். பணம் திரும்பப் பெற முடியாது.',
    'Scammers promote Forex/Binary Options trading promising quick profits through fake apps/websites. Money cannot be withdrawn once deposited.',
    'குறுகிய காலத்தில் அதிக லாபம்|போலி Trading ஆப்|ஆரம்பத்தில் சிறிய லாபம் காட்டுவது|பணம் எடுக்க Tax/Fee கேட்பது|SEBI பதிவு இல்லாத தளம்',
    'Quick high profits|Fake trading app|Showing small profits initially|Tax/Fee to withdraw money|Non-SEBI registered platform',
    'Start Forex trading with just Rs.5,000. Our AI robot trades automatically. Average daily profit 10-20%. Download our app and start earning today!',
    'இந்தியாவில் Forex Trading SEBI/RBI கட்டுப்பாட்டில் உள்ளது. அறியாத தளங்களில் Trading செய்யாதீர்கள். AI robot trading என்பது மோசடி. SEBI பதிவு செய்யப்பட்ட தரகர்களை மட்டும் பயன்படுத்தவும்.',
    'Forex Trading in India is regulated by SEBI/RBI. Do not trade on unknown platforms. AI robot trading is a scam. Use only SEBI registered brokers.',
    'Cyber Crime Portal / SEBI',
    '1930'
),
(
    'தங்க முதலீடு மோசடி',
    'Gold Investment Scam',
    'shopping',
    'குறைந்த விலையில் தங்கம் வாங்கலாம், மாதாந்திர திட்டத்தில் தங்கம் சேர்க்கலாம் என்று போலி நிறுவனங்கள் ஏமாற்றுவது.',
    'Fake companies offer gold at below market rates or monthly gold saving schemes and disappear with the collected money.',
    'சந்தை விலையை விட குறைவு|BIS முத்திரை இல்லாத தங்கம்|போலி ஹால்மார்க்|அதிக Bonus/Discount|அறியாத நிறுவனம்',
    'Below market rate|Gold without BIS hallmark|Fake hallmark|High bonus/discount|Unknown company',
    'Buy 22K gold at Rs.5,500/gram (market: Rs.7,200). Monthly gold saving scheme: Invest Rs.5,000/month, get 15 grams free gold after 11 months!',
    'தங்கம் சந்தை விலையை விட குறைவாக கிடைக்காது. BIS ஹால்மார்க் உள்ள தங்கத்தை மட்டும் வாங்குங்கள். அங்கீகரிக்கப்பட்ட நகைக்கடைகளில் மட்டும் வாங்குங்கள்.',
    'Gold is never available below market rate. Buy only BIS hallmarked gold. Purchase only from authorized jewelers.',
    'Consumer Forum / Police',
    '1800-11-4000'
);

-- ============================================================
-- IDENTITY THEFT SCAMS (type: 'identity')
-- ============================================================

INSERT INTO scam_patterns (name_tamil, name_english, type, description_tamil, description_english, red_flags_tamil, red_flags_english, example_messages, prevention_tamil, prevention_english, report_to, report_number) VALUES
(
    'SIM Swap மோசடி',
    'SIM Swap Fraud',
    'identity',
    'மோசடி செய்பவர்கள் உங்கள் SIM-ஐ போலி ஆவணங்களால் Duplicate SIM எடுத்து, உங்கள் OTP-களை பெற்று வங்கிக் கணக்கில் உள்ள பணத்தை திருடுவார்கள்.',
    'Scammers get a duplicate SIM using forged documents, intercept your OTPs, and steal money from your bank accounts.',
    'திடீரென SIM வேலை செய்யாமல் போவது|அறியாத OTP வருவது|வங்கி அறிவிப்பு வருவது|தொலைபேசி சேவை நிறுத்தம்',
    'SIM suddenly stops working|Unknown OTPs received|Bank notifications received|Phone service disruption',
    NULL,
    'SIM வேலை செய்யவில்லை என்றால் உடனே Mobile Operator-ஐ அழைக்கவும். வங்கிக்கு தெரிவித்து கணக்கை முடக்கவும். SIM Lock/SIM PIN இயக்கவும். e-SIM-க்கு மாறுங்கள்.',
    'If SIM stops working, immediately call mobile operator. Inform bank and block account. Enable SIM Lock/SIM PIN. Switch to e-SIM if possible.',
    'Cyber Crime Portal / Mobile Operator / Bank',
    '1930'
),
(
    'ஆதார் தவறாக பயன்படுத்தல்',
    'Aadhaar Misuse',
    'identity',
    'உங்கள் ஆதார் நகலை பயன்படுத்தி போலி SIM, போலி வங்கிக் கணக்கு, போலி கடன் வாங்குவது.',
    'Scammers use photocopies of your Aadhaar to obtain fake SIMs, open fake bank accounts, or take loans in your name.',
    'அறியாத கடன் அறிவிப்பு|CIBIL Score மாற்றம்|அறியாத SIM பதிவு|தெரியாத வங்கிக் கணக்கு',
    'Unknown loan notifications|CIBIL Score change|Unknown SIM registration|Unknown bank account',
    NULL,
    'ஆதார் நகலை யாரிடமும் தேவையின்றி கொடுக்காதீர்கள். Masked Aadhaar (கடைசி 4 எண் மட்டும்) பயன்படுத்துங்கள். mAadhaar ஆப்பில் Biometric Lock இயக்கவும். UIDAI-யில் Authentication History சரிபார்க்கவும்.',
    'Do not give Aadhaar copy unnecessarily. Use Masked Aadhaar (last 4 digits only). Enable Biometric Lock in mAadhaar app. Check Authentication History at UIDAI.',
    'UIDAI / Cyber Crime Portal',
    '1930'
),
(
    'PAN கார்டு மோசடி',
    'PAN Card Fraud',
    'identity',
    'உங்கள் PAN எண்ணை பயன்படுத்தி போலி வருமான வரி தாக்கல், போலி நிறுவனப் பதிவு செய்வது.',
    'Scammers use your PAN number to file fake income tax returns or register fake companies in your name.',
    'எதிர்பாராத வரி நோட்டீஸ்|அறியாத நிறுவனத்தில் Director ஆக இருப்பது|Form 26AS-ல் அறியாத வருமானம்|வரி திரும்பப்பெறுதல் நிராகரிப்பு',
    'Unexpected tax notice|Being director in unknown company|Unknown income in Form 26AS|Tax refund rejection',
    NULL,
    'PAN எண்ணை தேவையின்றி பகிர வேண்டாம். incometax.gov.in-ல் Form 26AS-ஐ தவறாமல் சரிபார்க்கவும். PAN தவறாக பயன்படுத்தப்பட்டால் IT Department-ல் புகார் செய்யவும்.',
    'Do not share PAN number unnecessarily. Regularly check Form 26AS at incometax.gov.in. If PAN is misused, complain to IT Department.',
    'Income Tax Department / Cyber Crime',
    '1930'
),
(
    'போலி கடன் ஆப் Blackmail',
    'Fake Loan App Blackmail',
    'identity',
    'போலி கடன் ஆப்கள் மூலம் சிறிய கடன் வாங்கிய பின், Contacts, Gallery அணுகல் பயன்படுத்தி morphed photos மூலம் Blackmail செய்வது.',
    'After taking small loans through fake loan apps, scammers use Contacts and Gallery access to blackmail victims with morphed photos.',
    'ஆப் Contacts/Gallery அணுகல் கேட்பது|அதிக வட்டி|குறுகிய திருப்பிச்செலுத்தல் காலம்|தொடர்பு எண்களுக்கு அவமானப்படுத்தும் செய்தி|Morphed Photos அனுப்புவது',
    'App asking Contacts/Gallery access|High interest rate|Short repayment period|Shaming messages to contacts|Sending morphed photos',
    NULL,
    'அறியாத கடன் ஆப்களை பதிவிறக்காதீர்கள். RBI பதிவு செய்யப்பட்ட NBFC-களில் மட்டும் கடன் வாங்குங்கள். Blackmail செய்தால் உடனே 1930-ல் புகார் செய்யுங்கள். Contacts/Gallery permission கொடுக்காதீர்கள்.',
    'Do not download unknown loan apps. Borrow only from RBI registered NBFCs. If blackmailed, immediately report to 1930. Do not grant Contacts/Gallery permission.',
    'Cyber Crime Portal / RBI',
    '1930'
);

-- ============================================================
-- LOCAL SCAMS (type: 'local')
-- ============================================================

INSERT INTO scam_patterns (name_tamil, name_english, type, description_tamil, description_english, red_flags_tamil, red_flags_english, example_messages, prevention_tamil, prevention_english, report_to, report_number) VALUES
(
    'கோயில் நன்கொடை மோசடி',
    'Temple Donation Fraud',
    'local',
    'பிரபல கோயில்கள் பெயரில் போலி நன்கொடை வசூல். போலி இணையதளம் மூலம் ஆன்லைனில் நன்கொடை வசூலிப்பது.',
    'Fake donation collection in the name of famous temples. Online donation collection through fake websites impersonating temple trusts.',
    'அதிகாரப்பூர்வ அல்லாத இணையதளம்|கோயில் நிர்வாகம் அங்கீகரிக்காத நபர்|ரசீது இல்லாமல் வசூல்|UPI மூலம் தனிநபர் கணக்குக்கு பணம் கேட்பது',
    'Unofficial website|Person not authorized by temple management|Collection without receipt|UPI to personal account',
    'Donate to Tirupati Balaji Temple online. Special darshan for donors of Rs.5,000+. Transfer to GPay: templedonation@ybl',
    'கோயிலின் அதிகாரப்பூர்வ இணையதளத்தில் மட்டும் நன்கொடை செய்யுங்கள். TTD: tirumala.org, மீனாட்சி: maduraimeenakshi.hrce.tn.gov.in. தனிநபர் UPI-க்கு பணம் அனுப்ப வேண்டாம்.',
    'Donate only on temple official website. TTD: tirumala.org, Meenakshi: maduraimeenakshi.hrce.tn.gov.in. Do not send money to personal UPI.',
    'HR&CE Department / Police',
    '100'
),
(
    'போலி தொண்டு நிறுவன மோசடி',
    'Fake Charity Scam',
    'local',
    'இயற்கை பேரிடர், விபத்து போன்ற சமயங்களில் போலி NGO/தொண்டு நிறுவனம் என்று கூறி நன்கொடை வசூலிப்பது.',
    'Fake NGOs/charities collect donations during natural disasters or accidents by impersonating legitimate organizations.',
    'புதிய தொண்டு நிறுவனம்|80G சான்றிதழ் இல்லை|சமூக ஊடகத்தில் மட்டும் இருப்பது|நிதிப் பயன்பாட்டு விவரம் இல்லை|உணர்வுகளைத் தூண்டும் புகைப்படங்கள்',
    'New charity organization|No 80G certificate|Only on social media|No financial usage details|Emotionally manipulative photos',
    NULL,
    'நம்பகமான தொண்டு நிறுவனங்களில் மட்டும் நன்கொடை செய்யுங்கள். 80G சான்றிதழ் கேளுங்கள். Chief Minister Relief Fund போன்ற அரசு நிதிக்கு நன்கொடை செய்யலாம்.',
    'Donate only to trusted charities. Ask for 80G certificate. Donate to government funds like Chief Minister Relief Fund.',
    'Police / Charity Commissioner',
    '100'
),
(
    'நில ஆவண மோசடி',
    'Land Document Fraud',
    'local',
    'போலி பட்டா, போலி விற்பனை ஆவணம், ஏற்கனவே விற்கப்பட்ட நிலத்தை மீண்டும் விற்பது போன்ற நில மோசடிகள் தமிழ்நாட்டில் பரவலானவை.',
    'Fake patta, forged sale deeds, selling already-sold land are common land frauds in Tamil Nadu.',
    'மிகக் குறைந்த நில விலை|அவசரமாக விற்பனை|தெளிவான உரிமை ஆவணம் இல்லை|பதிவு செய்யப்படாத ஆவணம்|EC-யில் முரண்பாடு|நில அளவீடு சான்று இல்லை',
    'Very low land price|Urgent sale|No clear title document|Unregistered document|Discrepancy in EC|No survey measurement proof',
    NULL,
    'நில வாங்குமுன் EC (Encumbrance Certificate) சரிபார்க்கவும். tnreginet.gov.in-ல் ஆவணங்களை சரிபார்க்கவும். வழக்கறிஞர் உதவியுடன் ஆவணங்களை சோதிக்கவும். Village Administrative Officer (VAO) இடம் உறுதிப்படுத்தவும்.',
    'Check EC (Encumbrance Certificate) before buying land. Verify documents at tnreginet.gov.in. Get documents verified by a lawyer. Confirm with Village Administrative Officer (VAO).',
    'Registration Department / Police',
    '100'
),
(
    'போலி வாடகை மோசடி',
    'Fake Rental Scam',
    'local',
    'சமூக ஊடகங்களில் குறைந்த வாடகையில் போலி வீடு/அறை விளம்பரம் போட்டு, Advance பணம் வாங்கி ஏமாற்றுவது.',
    'Fake house/room rental listings on social media at low rates to collect advance payment and disappear.',
    'மிகக் குறைந்த வாடகை|Advance பணம் உடனே கேட்பது|வீட்டைப் பார்க்க அனுமதிக்காமை|போலி உரிமையாளர்|வேறொருவரின் வீட்டை காட்டுவது',
    'Very low rent|Demanding advance immediately|Not allowing to see the house|Fake owner|Showing someone else house',
    'Spacious 2BHK in T.Nagar for Rs.5,000/month. Army officer transferred. Pay Rs.20,000 advance to book. Contact WhatsApp 9876543210.',
    'வீட்டை நேரில் பார்க்காமல் Advance தர வேண்டாம். உரிமை ஆவணங்களை சரிபார்க்கவும். அக்கம்பக்கத்தினரிடம் விசாரிக்கவும். Rental Agreement போடவும்.',
    'Do not pay advance without physically seeing the house. Verify ownership documents. Enquire with neighbors. Insist on Rental Agreement.',
    'Police',
    '100'
),
(
    'போலி வேலை ஆள்சேர்ப்பு முகவர் மோசடி',
    'Fake Recruitment Agent Scam',
    'local',
    'வெளிநாட்டு வேலை வாய்ப்பு என்று கூறி பதிவுக் கட்டணம், விசா கட்டணம், பயிற்சிக் கட்டணம் என்று பல கட்டணங்கள் வசூலிக்கும் போலி ஆள்சேர்ப்பு முகவர்கள்.',
    'Fake recruitment agents promise foreign jobs and collect multiple fees for registration, visa, training, etc.',
    'அதிகக் கட்டணம்|PoE (Protector of Emigrants) அங்கீகாரம் இல்லை|விசா கட்டணம் என்று பணம் கேட்பது|பல கட்டணங்கள்|குறிப்பிட்ட நிறுவனப் பெயர் இல்லை',
    'Excessive fees|No PoE approval|Money for visa charges|Multiple fees|No specific company name',
    'Canada/Dubai/Singapore job. Salary Rs.1,50,000/month. Registration fee Rs.25,000. Visa processing Rs.50,000. Total package Rs.1,00,000.',
    'PoE (Protector of Emigrants) அங்கீகரிக்கப்பட்ட முகவர்களிடம் மட்டும் பதிவு செய்யுங்கள். emigrate.gov.in-ல் முகவரை சரிபார்க்கவும். அதிகக் கட்டணம் வசூலிப்பவர்களைத் தவிர்க்கவும்.',
    'Register only with PoE approved agents. Verify agent at emigrate.gov.in. Avoid agents charging excessive fees.',
    'Protector of Emigrants / Police',
    '100'
),
(
    'கல்வி கட்டண மோசடி',
    'Education Fee Scam',
    'local',
    'Management Quota-ல் MBBS/Engineering seat வாங்கித் தருவதாக கூறி லட்சக்கணக்கில் பணம் வாங்கி ஏமாற்றுவது.',
    'Scammers promise MBBS/Engineering seats under Management Quota, collect lakhs of rupees, and disappear without delivering the seat.',
    'Management Quota seat வாக்குறுதி|குறைந்த மதிப்பெண்ணுக்கு seat|தரகர் மூலம் seat|ரசீது இல்லாமல் பணம் கேட்பது|கல்லூரி அதிகாரப்பூர்வ அறிவிப்பு இல்லை',
    'Management quota seat promise|Seat for low marks|Seat through broker|Money without receipt|No official college notification',
    'MBBS seat available at top Chennai medical college. Management quota. Only Rs.30 lakhs. Limited seats. Contact immediately.',
    'கல்வி நிறுவனங்களின் அதிகாரப்பூர்வ இணையதளத்தில் Counselling நடைமுறையை சரிபார்க்கவும். தரகர்கள் மூலம் seat வாங்க வேண்டாம். அரசு Counselling மூலமே சேரவும்.',
    'Check admission process on institution official website. Do not buy seats through brokers. Join only through government counselling.',
    'Police / Directorate of Medical Education',
    '100'
),
(
    'திருமண மோசடி',
    'Matrimonial Scam',
    'local',
    'திருமண இணையதளங்களில் போலி சுயவிவரம் பதிவு செய்து, NRI என்று காட்டி, திருமணத்திற்கு முன் பல காரணங்கள் கூறி பணம் கேட்பார்கள்.',
    'Scammers create fake profiles on matrimonial websites posing as NRIs and demand money for various reasons before marriage.',
    'NRI சுயவிவரம்|அதிக சம்பளம் காட்டுவது|விரைவாக திருமணம் முடிக்க விரும்புவது|விசா/விமான டிக்கெட் என்று பணம் கேட்பது|நேரில் சந்திக்க மறுப்பது',
    'NRI profile|Showing high salary|Wanting to marry quickly|Money for visa/flight ticket|Refusing to meet in person',
    NULL,
    'திருமண இணையதளங்களில் போலி சுயவிவரங்களை எச்சரிக்கையாக இருங்கள். நேரில் சந்திக்காமல் பணம் தர வேண்டாம். குடும்பத்தினரிடம் ஆலோசிக்கவும். NRI-யின் Passport, Visa-ஐ சரிபார்க்கவும்.',
    'Be cautious of fake profiles on matrimonial websites. Do not send money without meeting in person. Consult family members. Verify NRI Passport and Visa.',
    'Cyber Crime Portal / Police',
    '1930'
),
(
    'போலி ஆஸ்பத்திரி/மருத்துவர் மோசடி',
    'Fake Hospital/Doctor Scam',
    'local',
    'போலி மருத்துவர்கள் இல்லாத நோயைக் கண்டுபிடித்ததாகக் கூறி அதிகக் கட்டணம் வசூலிப்பது. Google-ல் போலி ஆஸ்பத்திரி தொலைபேசி எண் போட்டு ஏமாற்றுவது.',
    'Fake doctors diagnose non-existent diseases and charge excessive fees. Fake hospital phone numbers on Google used to defraud patients.',
    'Google-ல் போலி எண்|இல்லாத நோய் கண்டுபிடிப்பு|அதிக சிகிச்சை கட்டணம்|அரசு மருத்துவமனை சரிபார்ப்பு இல்லை|மருத்துவர் பதிவு எண் இல்லை',
    'Fake number on Google|Non-existent disease diagnosis|Excessive treatment fees|No government hospital verification|No doctor registration number',
    NULL,
    'Google-ல் வரும் ஆஸ்பத்திரி எண்களை நம்ப வேண்டாம். ஆஸ்பத்திரியின் அதிகாரப்பூர்வ இணையதளத்தில் எண்ணை சரிபார்க்கவும். Tamil Nadu Medical Council-ல் மருத்துவர் பதிவை உறுதிப்படுத்தவும். Second opinion பெறுங்கள்.',
    'Do not trust hospital numbers from Google. Verify number on hospital official website. Confirm doctor registration at Tamil Nadu Medical Council. Get a second opinion.',
    'Tamil Nadu Medical Council / Police',
    '100'
);
