-- Tamil Nadu Festivals (திருவிழாக்கள்) Data
-- Major Tamil, Hindu, and secular festivals celebrated in Tamil Nadu
-- Source: VAZHI Tamil Knowledge corpus

-- Clear existing data
DELETE FROM festivals;

-- Pongal Festival (4 days)
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('போகிப் பண்டிகை', 'Bhogi', 'தை', 'January', 1, 'பழைய பொருட்களை அகற்றி புதிய தொடக்கத்தை குறிக்கும் விழா. இந்திரனுக்கு நன்றி தெரிவிக்கும் நாள். தை மாதத்தின் முதல் நாளுக்கு முந்தைய நாள் கொண்டாடப்படுகிறது.', 'Festival marking the removal of old things and new beginnings. A day to express gratitude to Lord Indra. Celebrated the day before the first day of the Tamil month Thai.', 'பழைய உடைகள் மற்றும் பொருட்களை போகி மூட்டத்தில் எரித்தல். வீட்டை சுத்தம் செய்தல். கோலம் போடுதல்.', 'Burning old clothes and belongings in a bonfire (Bhogi Moottam). Cleaning the house. Drawing kolam designs.', 'harvest', 'Tamil Nadu');

INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('தைப்பொங்கல்', 'Thai Pongal', 'தை', 'January', 1, 'தமிழர்களின் மிக முக்கியமான அறுவடைத் திருவிழா. சூரியனுக்கு நன்றி தெரிவிக்கும் நாள். புதிய அரிசியில் பொங்கல் வைத்து கொண்டாடப்படுகிறது. தமிழ் கலாச்சாரத்தின் அடையாள விழா.', 'The most important harvest festival of Tamils. A day to express gratitude to the Sun God. Celebrated by cooking Pongal with newly harvested rice. An iconic festival of Tamil culture.', 'புதிய மண் பானையில் பால் பொங்கல் வைத்தல். "பொங்கலோ பொங்கல்" என்று கூறுதல். கரும்பு, மஞ்சள் கொத்து வைத்து அலங்கரித்தல். சூரியனுக்கு படைத்தல்.', 'Cooking milk Pongal in a new clay pot. Chanting "Pongalo Pongal". Decorating with sugarcane and turmeric bunches. Offering to the Sun God.', 'harvest', 'Tamil Nadu');

INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('மாட்டுப்பொங்கல்', 'Mattu Pongal', 'தை', 'January', 1, 'கால்நடைகளுக்கு நன்றி தெரிவிக்கும் நாள். மாடுகள் விவசாயத்தில் ஆற்றும் பெரும் பணிக்கு நன்றி செலுத்தும் விழா. ஜல்லிக்கட்டு நடைபெறும் நாள்.', 'A day to express gratitude to cattle. A festival to thank the bulls and cows for their great service in agriculture. Jallikattu (bull-taming sport) is held on this day.', 'மாடுகளை குளிப்பாட்டி, கொம்புகளுக்கு வண்ணம் பூசுதல். மணி, பூ மாலை கட்டுதல். ஜல்லிக்கட்டு நடத்துதல். மாடுகளுக்கு பொங்கல் படைத்தல்.', 'Bathing cattle and painting their horns with colors. Tying bells and flower garlands. Conducting Jallikattu. Offering Pongal to the cattle.', 'harvest', 'Tamil Nadu');

INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('காணும் பொங்கல்', 'Kaanum Pongal', 'தை', 'January', 1, 'குடும்பத்தினர் ஒன்று கூடி மகிழும் நாள். சகோதர சகோதரிகள் ஒருவருக்கொருவர் வாழ்த்துக்கள் தெரிவிக்கும் நாள். சுற்றுலா செல்வது வழக்கம்.', 'A day for family gatherings and celebrations. A day when brothers and sisters exchange greetings. It is customary to go on outings and excursions.', 'உறவினர் வீடுகளுக்கு செல்லுதல். கோவில்களுக்கு சுற்றுலா செல்லுதல். இளநீர், பழங்கள் வைத்து படைத்தல். பறவைகளுக்கு உணவு வைத்தல்.', 'Visiting relatives'' homes. Going on temple excursions. Offering tender coconut and fruits. Feeding birds.', 'harvest', 'Tamil Nadu');

-- Tamil New Year
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('தமிழ்ப்புத்தாண்டு', 'Tamil New Year (Puthandu)', 'சித்திரை', 'April', 1, 'தமிழ் நாட்காட்டியின் முதல் நாள். சித்திரை மாதம் முதல் நாளில் கொண்டாடப்படுகிறது. புத்தாண்டு பலன்களை பஞ்சாங்கம் படித்து அறியும் நாள்.', 'The first day of the Tamil calendar. Celebrated on the first day of the Tamil month Chithirai. A day to read the Panchanga (almanac) for new year predictions.', 'காலையில் மாங்கனி, வேப்பம்பூ, புளி, வெல்லம், நெல்லிக்காய், மிளகாய் கலந்த பானகம் குடித்தல். புது வருட பஞ்சாங்கம் படித்தல். கோவில் தரிசனம்.', 'Drinking a mixture of mango, neem flowers, tamarind, jaggery, gooseberry, and chili in the morning. Reading the new year Panchanga. Visiting temples.', 'cultural', 'Tamil Nadu');

-- Chithirai Thiruvizha
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('சித்திரைத் திருவிழா', 'Chithirai Thiruvizha', 'சித்திரை', 'April-May', 15, 'மதுரை மீனாட்சி அம்மன் கோவிலில் நடைபெறும் மிகப்பெரிய விழா. மீனாட்சி திருக்கல்யாணம் மற்றும் அழகர் ஆற்றில் இறங்கும் நிகழ்வு உலகப் புகழ் பெற்றவை.', 'The grand festival held at the Meenakshi Amman Temple in Madurai. The Meenakshi Thirukalyanam and Alagar entering the Vaigai river are world-famous events.', 'மீனாட்சி சுந்தரேஸ்வரர் திருக்கல்யாணம் நடத்துதல். கள்ளழகர் வைகை ஆற்றில் இறங்குதல். தேர் திருவிழா. பல்லாயிரக்கணக்கான பக்தர்கள் குழுமுதல்.', 'Conducting the divine wedding of Meenakshi and Sundareswarar. Kallalagar entering the Vaigai river. Chariot festival. Hundreds of thousands of devotees gathering.', 'religious', 'மதுரை, Tamil Nadu');

-- Chittirai Pournami
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('சித்திரை பௌர்ணமி', 'Chittirai Pournami', 'சித்திரை', 'April-May', 1, 'சித்திரை மாத முழுநிலவு நாள். புத்தர் பிறந்த நாளாகவும் கொண்டாடப்படுகிறது. திருவண்ணாமலையில் கிரிவலம் செல்வது சிறப்பு.', 'The full moon day of the Tamil month Chithirai. Also celebrated as Buddha Purnima. Girivalam (circumambulation) at Thiruvannamalai is especially significant.', 'திருவண்ணாமலையில் கிரிவலம் செல்லுதல். நிலவுக்கு படையல் வைத்தல். கோவில் வழிபாடு செய்தல்.', 'Girivalam at Thiruvannamalai. Offering to the moon. Temple worship.', 'religious', 'Tamil Nadu');

-- Aadi festivals
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஆடிப்பெருக்கு', 'Aadi Perukku', 'ஆடி', 'July-August', 1, 'நீர்நிலைகளுக்கு நன்றி தெரிவிக்கும் விழா. ஆடி 18-ம் நாள் கொண்டாடப்படுகிறது. ஆறுகள் மற்றும் நீர்நிலைகளின் வளத்திற்கு நன்றி செலுத்தும் நாள்.', 'A festival to express gratitude to water bodies. Celebrated on the 18th day of the Tamil month Aadi. A day to thank rivers and water bodies for their abundance.', 'ஆற்றங்கரையில் சமைத்து படைத்தல். நீர்நிலைகளில் பூஜை செய்தல். கரும்பு, பழங்கள், இனிப்புகள் படைத்தல். குடும்பத்துடன் ஆற்றங்கரைக்கு செல்லுதல்.', 'Cooking and offering food on riverbanks. Performing puja at water bodies. Offering sugarcane, fruits, and sweets. Going to riverbanks with family.', 'harvest', 'Tamil Nadu');

INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஆடி அமாவாசை', 'Aadi Amavasai', 'ஆடி', 'July-August', 1, 'முன்னோர்களுக்கு நன்றி செலுத்தும் நாள். ஆடி மாத அமாவாசையில் இறந்த முன்னோர்களின் ஆன்மா சாந்தி பெற பூஜை செய்யப்படுகிறது.', 'A day to honor ancestors. On the new moon day of Aadi month, rituals are performed for the peace of departed ancestors'' souls.', 'கடலில் அல்லது ஆற்றில் தர்ப்பணம் செய்தல். முன்னோர்களுக்கு எள் தண்ணீர் விடுதல். சிரார்த்தம் செய்தல். பிண்டம் வைத்தல்.', 'Performing tharpanam in the sea or river. Offering sesame water to ancestors. Performing shraddha ceremony. Offering pinda.', 'religious', 'Tamil Nadu');

INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஆடி வெள்ளி', 'Aadi Velli', 'ஆடி', 'July-August', 1, 'ஆடி மாதத்தின் ஒவ்வொரு வெள்ளிக்கிழமையும் அம்மனை வழிபடும் நாள். பெண்கள் விரதம் இருந்து அம்மன் கோவிலுக்கு செல்வது வழக்கம்.', 'Every Friday of the Tamil month Aadi is dedicated to worshipping the Goddess. It is customary for women to fast and visit Amman temples.', 'அம்மன் கோவிலுக்கு செல்லுதல். எலுமிச்சை விளக்கு ஏற்றுதல். காவடி எடுத்தல். பொங்கல் வைத்து படைத்தல்.', 'Visiting Amman temples. Lighting lemon lamps. Carrying Kavadi. Cooking and offering Pongal.', 'religious', 'Tamil Nadu');

-- Vinayagar Chaturthi
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('விநாயகர் சதுர்த்தி', 'Vinayagar Chaturthi', 'ஆவணி', 'August-September', 1, 'விநாயகப் பெருமானின் பிறந்தநாள் விழா. அனைத்து தொடக்கங்களுக்கும் முதலில் வணங்கப்படும் கணபதியின் சிறப்பு நாள்.', 'Birthday celebration of Lord Vinayagar (Ganesha). A special day dedicated to Ganapathi, who is worshipped first before all beginnings.', 'களிமண்ணில் விநாயகர் சிலை செய்தல். கொழுக்கட்டை, மோதகம் படைத்தல். அருகம்புல் மாலை சூட்டுதல். மாலையில் நீர்நிலையில் கரைத்தல்.', 'Making Vinayagar idols from clay. Offering kozhukattai and modakam. Adorning with arugampul garland. Immersing in water bodies in the evening.', 'religious', 'Tamil Nadu');

-- Krishna Jayanthi
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('கிருஷ்ண ஜெயந்தி', 'Krishna Jayanthi (Gokulashtami)', 'ஆவணி', 'August-September', 1, 'கிருஷ்ணரின் பிறந்தநாள் விழா. கிருஷ்ணரின் குழந்தைப் பருவ லீலைகளை நினைவு கூரும் நாள்.', 'Birthday celebration of Lord Krishna. A day to commemorate the childhood exploits of Krishna.', 'நள்ளிரவு வரை விரதம் இருத்தல். வெண்ணெய், பால், தயிர் படைத்தல். உறியடி நிகழ்ச்சி நடத்துதல். கிருஷ்ணர் சிலையை அலங்கரித்தல்.', 'Fasting until midnight. Offering butter, milk, and curd. Conducting Uriyadi (pot-breaking) events. Decorating Krishna idol.', 'religious', 'Tamil Nadu');

-- Navaratri
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('நவராத்திரி', 'Navaratri', 'புரட்டாசி', 'September-October', 9, 'ஒன்பது இரவுகள் தேவியை வழிபடும் மாபெரும் விழா. துர்கை, லட்சுமி, சரஸ்வதி ஆகிய மூன்று தேவியரை மூன்று நாட்கள் வீதம் வழிபடுவது மரபு.', 'A grand nine-night festival dedicated to worshipping the Goddess. It is tradition to worship the three goddesses Durga, Lakshmi, and Saraswati for three days each.', 'கொலு வைத்தல் (படிகளில் பொம்மைகள் அலங்கரித்தல்). சுண்டல் வகைகள் படைத்தல். வீட்டுக்கு வீடு கொலு பார்க்க செல்லுதல். சரஸ்வதி பூஜை, ஆயுத பூஜை நடத்துதல்.', 'Setting up Golu (arranging dolls on steps). Offering varieties of sundal. Visiting homes to see Golu displays. Conducting Saraswati Puja and Ayudha Puja.', 'religious', 'Tamil Nadu');

-- Saraswati Pooja
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('சரஸ்வதி பூஜை', 'Saraswati Pooja', 'புரட்டாசி', 'September-October', 1, 'கல்வி கடவுளான சரஸ்வதி தேவியை வழிபடும் நாள். நவராத்திரியின் ஒன்பதாவது நாள். புத்தகங்கள் மற்றும் இசைக் கருவிகளை வழிபடும் நாள்.', 'A day to worship Goddess Saraswati, the deity of learning. The ninth day of Navaratri. A day to worship books and musical instruments.', 'புத்தகங்கள், இசைக்கருவிகள் வைத்து பூஜை செய்தல். குழந்தைகளுக்கு எழுத்தறிவித்தல் (வித்யாரம்பம்). அக்ஷரஅப்யாசம் செய்தல்.', 'Performing puja with books and musical instruments. Teaching children to write for the first time (Vidyarambam). Performing Akshara Abhyasam.', 'religious', 'Tamil Nadu');

-- Vijayadashami
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('விஜயதசமி', 'Vijayadashami (Dussehra)', 'புரட்டாசி', 'September-October', 1, 'தீமையின் மீது நன்மை வெற்றி பெற்ற நாள். நவராத்திரிக்கு அடுத்த நாள். புதிய கல்வி மற்றும் தொழில்களைத் தொடங்க மிகவும் சிறந்த நாள்.', 'The day good triumphed over evil. The day after Navaratri. Considered the most auspicious day to begin new learning and ventures.', 'குழந்தைகளை பள்ளியில் சேர்த்தல். புதிய படிப்பு தொடங்குதல். ஆயுத பூஜை செய்தல். வீடுகளில் வைத்த புத்தகங்களை எடுத்து படிக்கத் தொடங்குதல்.', 'Enrolling children in school. Starting new studies. Performing Ayudha Puja. Taking out books kept for puja and beginning to read.', 'religious', 'Tamil Nadu');

-- Deepavali
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('தீபாவளி', 'Deepavali', 'ஐப்பசி', 'October-November', 1, 'ஒளியின் திருவிழா. நரகாசுரனை கிருஷ்ணர் வதம் செய்ததை நினைவு கூரும் நாள். தமிழகத்தில் மிகவும் பிரபலமான விழாக்களில் ஒன்று.', 'The festival of lights. A day commemorating the slaying of Narakasura by Lord Krishna. One of the most popular festivals in Tamil Nadu.', 'அதிகாலையில் எண்ணெய் தேய்த்து குளித்தல். புதிய ஆடை அணிதல். பட்டாசு வெடித்தல். இனிப்புகள் மற்றும் பலகாரங்கள் செய்தல். உறவினர்களுக்கு பரிசுகள் அளித்தல்.', 'Oil bath early in the morning. Wearing new clothes. Bursting firecrackers. Making sweets and snacks. Giving gifts to relatives.', 'religious', 'Tamil Nadu');

-- Karthigai Deepam
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('கார்த்திகை தீபம்', 'Karthigai Deepam', 'கார்த்திகை', 'November-December', 1, 'தமிழர்களின் பாரம்பரிய ஒளி திருவிழா. திருவண்ணாமலையில் மகா தீபம் ஏற்றப்படும் நாள். சிவபெருமான் ஜோதி வடிவில் தோன்றிய நாள்.', 'The traditional festival of lights of Tamils. The day the Maha Deepam is lit at Thiruvannamalai. The day Lord Shiva appeared as a column of fire.', 'வீடுகளில் நெய் தீபம் ஏற்றுதல். திருவண்ணாமலையில் மகா தீபம் தரிசனம். அகல் விளக்குகள் ஏற்றி வீட்டை அலங்கரித்தல். பட்டாசு வெடித்தல்.', 'Lighting ghee lamps at home. Witnessing the Maha Deepam at Thiruvannamalai. Decorating homes with clay lamps. Bursting firecrackers.', 'religious', 'Tamil Nadu');

-- Thaipusam
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('தைப்பூசம்', 'Thaipusam', 'தை', 'January-February', 1, 'முருகப் பெருமானுக்கு அர்ப்பணிக்கப்பட்ட விழா. தேவியானி பார்வதி முருகனுக்கு வேல் வழங்கிய நாள். பழனி மற்றும் முருகன் கோவில்களில் சிறப்பாக கொண்டாடப்படுகிறது.', 'A festival dedicated to Lord Murugan. The day Goddess Parvati gave the Vel (lance) to Murugan. Celebrated grandly at Palani and other Murugan temples.', 'காவடி எடுத்தல். பால் குடம் எடுத்தல். விரதம் இருத்தல். முருகன் கோவிலுக்கு நடைபயணம் செல்லுதல். வேல் வழிபாடு செய்தல்.', 'Carrying Kavadi. Carrying milk pots. Observing fast. Walking pilgrimage to Murugan temples. Worshipping the Vel.', 'religious', 'Tamil Nadu');

-- Masi Magam
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('மாசி மகம்', 'Masi Magam', 'மாசி', 'February-March', 1, 'மாசி மாதம் மக நட்சத்திர நாளில் கொண்டாடப்படும் புனித நீராடல் விழா. கடல் நீராடல் மிகவும் புனிதமாக கருதப்படும் நாள். குடியாத்தம் கோவிலில் சிறப்பு விழா.', 'A sacred bathing festival celebrated on the Magam star day in the Tamil month Masi. Sea bathing is considered highly sacred on this day. Special celebrations at Kumbakonam temple.', 'கடலில் புனித நீராடல் செய்தல். கோவில் தீர்த்தவாரியில் கலந்து கொள்ளுதல். விக்ரகங்களை கடலில் எடுத்துச் செல்லுதல்.', 'Taking sacred bath in the sea. Participating in temple theerthavarI. Taking deity procession to the sea.', 'religious', 'Tamil Nadu');

-- Panguni Uthiram
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('பங்குனி உத்திரம்', 'Panguni Uthiram', 'பங்குனி', 'March-April', 1, 'பங்குனி மாதம் உத்திர நட்சத்திர நாளில் கொண்டாடப்படும் விழா. பல தெய்வத் திருமணங்கள் நடைபெற்ற நாள். சிவன், முருகன், பெருமாள் கோவில்களில் சிறப்பு விழா.', 'Festival celebrated on the Uttiram star day in the Tamil month Panguni. A day when many divine marriages took place. Special festivals at Shiva, Murugan, and Perumal temples.', 'கோவில்களில் தெய்வத் திருக்கல்யாண நிகழ்ச்சி. சிறப்பு அபிஷேகம். தேர் திருவிழா. பக்தர்கள் கூட்டமாக வழிபாடு.', 'Divine wedding ceremonies at temples. Special abhishekam. Chariot festival. Devotees worshipping in large gatherings.', 'religious', 'Tamil Nadu');

-- Skanda Sashti
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('கந்த சஷ்டி', 'Skanda Sashti', 'ஐப்பசி', 'October-November', 6, 'முருகப் பெருமான் சூரபத்மனை வதம் செய்த நாள். ஆறு நாட்கள் விரதம் இருந்து கொண்டாடப்படுகிறது. திருச்செந்தூரில் மிகச் சிறப்பாக கொண்டாடப்படுகிறது.', 'The day Lord Murugan vanquished the demon Surapadman. Celebrated with six days of fasting. Celebrated most grandly at Thiruchendur.', 'ஆறு நாட்கள் விரதம் இருத்தல். கந்த சஷ்டி கவசம் படித்தல். சூரசம்ஹாரம் நிகழ்ச்சி. திருச்செந்தூர் கோவிலில் சிறப்பு வழிபாடு.', 'Observing six days of fasting. Reciting Kanda Sashti Kavacham. Soorasamharam event. Special worship at Thiruchendur temple.', 'religious', 'Tamil Nadu');

-- Vaikunta Ekadashi
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('வைகுண்ட ஏகாதசி', 'Vaikunta Ekadashi', 'மார்கழி', 'December-January', 1, 'வைணவ மரபின் மிக முக்கியமான விழா. வைகுண்டத்தின் வாசல் திறக்கப்படும் நாள் என்று நம்பப்படுகிறது. ஸ்ரீரங்கம் கோவிலில் சிறப்பாக கொண்டாடப்படுகிறது.', 'The most important festival of the Vaishnava tradition. It is believed that the gates of Vaikunta (heaven) open on this day. Celebrated grandly at the Srirangam temple.', 'சொர்க்கவாசல் வழியாக நடந்து செல்லுதல். விரதம் இருத்தல். திருப்பாவை, திருவெம்பாவை பாடுதல். பெருமாள் கோவில்களில் சிறப்பு தரிசனம்.', 'Walking through the Sorgavasal (gate of heaven). Observing fast. Singing Thiruppavai and Thiruvempavai. Special darshan at Perumal temples.', 'religious', 'Tamil Nadu');

-- Thiruvonam
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('திருவோணம்', 'Thiruvonam', 'ஆவணி', 'August-September', 1, 'மகாபலி மன்னன் மண்ணுலகிற்கு திரும்பி வரும் நாள் என்று நம்பப்படுகிறது. கேரள மாநிலத்தின் முக்கிய விழா. தமிழகத்திலும் குறிப்பாக எல்லை மாவட்டங்களில் கொண்டாடப்படுகிறது.', 'It is believed to be the day King Mahabali returns to the earthly world. A major festival of Kerala state. Also celebrated in Tamil Nadu, especially in border districts.', 'பூக்கள் வைத்து பூக்களம் அலங்கரித்தல். ஓணசத்யா உணவு தயாரித்தல். புதிய ஆடை அணிதல்.', 'Decorating floral carpet (Pookalam) with flowers. Preparing Ona Sadhya feast. Wearing new clothes.', 'cultural', 'கன்னியாகுமரி, நீலகிரி, Tamil Nadu');

-- Makar Sankranti
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('மகர சங்கராந்தி', 'Makar Sankranti', 'தை', 'January', 1, 'சூரியன் மகர ராசிக்கு இடம்பெயரும் நாள். உத்தராயணம் தொடங்கும் நாள். பொங்கலுடன் சேர்ந்து கொண்டாடப்படுகிறது.', 'The day the Sun transitions into the Makara (Capricorn) zodiac sign. The beginning of Uttarayanam. Celebrated along with Pongal.', 'எள், வெல்லம் கலந்து தயாரித்த இனிப்புகளை பகிர்தல். சூரிய வழிபாடு செய்தல். புனித நீராடல்.', 'Sharing sweets made with sesame and jaggery. Worshipping the Sun God. Sacred bathing.', 'harvest', 'Tamil Nadu');

-- Ayudha Puja
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஆயுத பூஜை', 'Ayudha Puja', 'புரட்டாசி', 'September-October', 1, 'கருவிகள் மற்றும் ஆயுதங்களை வழிபடும் நாள். நவராத்திரியின் ஒன்பதாவது நாள். வாகனங்கள், இயந்திரங்கள், கருவிகளுக்கு பூஜை செய்யப்படும் நாள்.', 'A day to worship tools and weapons. The ninth day of Navaratri. A day when vehicles, machines, and tools are worshipped.', 'வாகனங்களை கழுவி அலங்கரித்தல். கருவிகளுக்கு மஞ்சள், குங்குமம் வைத்து பூஜை செய்தல். புத்தகங்களுக்கு பூஜை செய்தல்.', 'Washing and decorating vehicles. Performing puja to tools with turmeric and kumkum. Performing puja to books.', 'religious', 'Tamil Nadu');

-- Varalakshmi Vratam
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('வரலட்சுமி விரதம்', 'Varalakshmi Vratam', 'ஆடி', 'July-August', 1, 'லட்சுமி தேவியை வழிபடும் விழா. ஆடி மாதத்தின் இரண்டாவது வெள்ளிக்கிழமையன்று கொண்டாடப்படுகிறது. செல்வம் மற்றும் நலன் வேண்டி பூஜை செய்யப்படுகிறது.', 'A festival dedicated to worshipping Goddess Lakshmi. Celebrated on the second Friday of the Tamil month Aadi. Puja is performed seeking wealth and well-being.', 'கலசம் வைத்து லட்சுமி பூஜை செய்தல். தோரணம் கட்டுதல். பலகாரங்கள் செய்தல். நோன்பு கயிறு கட்டுதல்.', 'Performing Lakshmi puja with kalasam. Tying thoranam. Making snacks. Tying the sacred thread.', 'religious', 'Tamil Nadu');

-- Maha Shivaratri
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('மகா சிவராத்திரி', 'Maha Shivaratri', 'மாசி', 'February-March', 1, 'சிவபெருமானுக்கு அர்ப்பணிக்கப்பட்ட மிக முக்கியமான இரவு. சிவன் அருவ மற்றும் உருவ வடிவங்களில் வெளிப்பட்ட நாள் என்று நம்பப்படுகிறது.', 'The most important night dedicated to Lord Shiva. It is believed to be the day Shiva manifested in both formless and form aspects.', 'இரவு முழுவதும் விழித்திருத்தல். சிவலிங்கத்திற்கு அபிஷேகம் செய்தல். பில்வ இலைகளால் அர்ச்சனை. விரதம் இருத்தல்.', 'Staying awake all night. Performing abhishekam to Shivalingam. Archana with bilva leaves. Observing fast.', 'religious', 'Tamil Nadu');

-- Arudra Darisanam
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஆருத்ரா தரிசனம்', 'Arudra Darisanam', 'மார்கழி', 'December-January', 1, 'சிவபெருமான் நடராஜர் வடிவில் ஆனந்த தாண்டவமாடிய நாள். மார்கழி மாதம் திருவாதிரை நட்சத்திர நாளில் கொண்டாடப்படுகிறது. சிதம்பரத்தில் மிகச் சிறப்பாக கொண்டாடப்படுகிறது.', 'The day Lord Shiva performed the cosmic dance (Ananda Tandavam) in the form of Nataraja. Celebrated on the Thiruvadhirai star day in the Tamil month Margazhi. Celebrated most grandly at Chidambaram.', 'திருவாதிரைக் களி செய்தல். நடராஜர் அபிஷேகம் தரிசித்தல். சிதம்பரம் கோவிலில் சிறப்பு வழிபாடு. இரவு முழுவதும் நடனம் மற்றும் இசை.', 'Making Thiruvadhirai kali. Witnessing Nataraja abhishekam. Special worship at Chidambaram temple. Dance and music throughout the night.', 'religious', 'Tamil Nadu');

-- Margazhi month observances
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('மார்கழி மாத வழிபாடு', 'Margazhi Month Observances', 'மார்கழி', 'December-January', 30, 'மார்கழி மாதம் முழுவதும் அதிகாலையில் கோவிலுக்கு சென்று வழிபடும் மரபு. திருப்பாவை மற்றும் திருவெம்பாவை பாடும் காலம். ஆன்மிகத்திற்கு மிகவும் சிறப்பான மாதம்.', 'The tradition of visiting temples early in the morning throughout the month of Margazhi. The period for singing Thiruppavai and Thiruvempavai. Considered the most auspicious month for spirituality.', 'அதிகாலையில் கோவிலுக்கு செல்லுதல். திருப்பாவை, திருவெம்பாவை பாடுதல். கோலம் போடுதல். பஜனை செய்தல்.', 'Visiting temples early in the morning. Singing Thiruppavai and Thiruvempavai. Drawing kolam designs. Performing bhajans.', 'religious', 'Tamil Nadu');

-- Puthandu Pirappu
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஆங்கிலப் புத்தாண்டு', 'English New Year', 'மார்கழி', 'January', 1, 'ஜனவரி 1 அன்று கொண்டாடப்படும் ஆங்கிலப் புத்தாண்டு. தமிழகத்திலும் ஆர்வமுடன் கொண்டாடப்படுகிறது.', 'English New Year celebrated on January 1st. Celebrated enthusiastically in Tamil Nadu as well.', 'நள்ளிரவு கொண்டாட்டம். புத்தாண்டு வாழ்த்துக்கள் பரிமாறுதல். கோவில் தரிசனம் செய்தல்.', 'Midnight celebrations. Exchanging New Year greetings. Visiting temples.', 'cultural', 'Tamil Nadu');

-- Independence Day
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('சுதந்திர தினம்', 'Independence Day', 'ஆடி/ஆவணி', 'August', 1, 'இந்தியா ஆங்கிலேயர்களிடம் இருந்து சுதந்திரம் பெற்ற நாள். ஆகஸ்ட் 15, 1947 அன்று சுதந்திரம் அடைந்ததை நினைவுகூரும் நாள்.', 'The day India gained independence from the British. A day to commemorate attaining freedom on August 15, 1947.', 'தேசிய கொடி ஏற்றுதல். தேசபக்தி பாடல்கள் பாடுதல். பள்ளிகள் மற்றும் அலுவலகங்களில் சிறப்பு நிகழ்ச்சிகள்.', 'Hoisting the national flag. Singing patriotic songs. Special events at schools and offices.', 'national', 'Tamil Nadu');

-- Republic Day
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('குடியரசு தினம்', 'Republic Day', 'தை', 'January', 1, 'இந்திய அரசியலமைப்பு சட்டம் நடைமுறைக்கு வந்த நாள். ஜனவரி 26, 1950 அன்று இந்தியா குடியரசாக மாறியதை நினைவுகூரும் நாள்.', 'The day the Indian Constitution came into effect. A day to commemorate India becoming a republic on January 26, 1950.', 'தேசிய கொடி ஏற்றுதல். அணிவகுப்பு நடத்துதல். தேசபக்தி நிகழ்ச்சிகள். விருதுகள் வழங்குதல்.', 'Hoisting the national flag. Conducting parades. Patriotic events. Awarding honors.', 'national', 'Tamil Nadu');

-- Gandhi Jayanti
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('காந்தி ஜெயந்தி', 'Gandhi Jayanti', 'புரட்டாசி', 'October', 1, 'மகாத்மா காந்தியின் பிறந்தநாள். அக்டோபர் 2 அன்று கொண்டாடப்படுகிறது. அகிம்சை மற்றும் அமைதி குறித்த விழிப்புணர்வு நாள்.', 'Birthday of Mahatma Gandhi. Celebrated on October 2nd. A day of awareness about non-violence and peace.', 'காந்தி சிலைக்கு மாலை அணிவித்தல். சுத்தம் செய்யும் பணிகள். அமைதி ஊர்வலம்.', 'Garlanding Gandhi statues. Cleanliness drives. Peace marches.', 'national', 'Tamil Nadu');

-- Ramzan (Eid ul-Fitr)
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('நோன்பு பெருநாள் (ரம்ஜான்)', 'Eid ul-Fitr (Ramzan)', '-', 'இஸ்லாமிய நாட்காட்டி அடிப்படையில்', 1, 'ரமலான் மாத நோன்பு முடிவில் கொண்டாடப்படும் பெருநாள். இஸ்லாமிய சமூகத்தின் மிக முக்கியமான விழா. அனைத்து சமூகத்தினரும் ஒற்றுமையுடன் கொண்டாடும் விழா.', 'The grand festival celebrated at the end of the Ramadan month of fasting. The most important festival of the Islamic community. A festival celebrated with unity by all communities.', 'தொழுகை நடத்துதல். புதிய ஆடை அணிதல். பிரியாணி மற்றும் சிறப்பு உணவுகள் தயாரித்தல். ஏழைகளுக்கு தானம் வழங்குதல் (ஜக்காத்). உறவினர்களை சந்தித்தல்.', 'Performing prayers. Wearing new clothes. Preparing biryani and special foods. Giving charity to the poor (Zakat). Meeting relatives.', 'secular', 'Tamil Nadu');

-- Bakrid (Eid ul-Adha)
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('பக்ரீத் (ஹஜ் பெருநாள்)', 'Eid ul-Adha (Bakrid)', '-', 'இஸ்லாமிய நாட்காட்டி அடிப்படையில்', 1, 'இப்ராஹிம் நபியின் தியாகத்தை நினைவு கூரும் பெருநாள். ஹஜ் புனித பயணத்துடன் தொடர்புடைய விழா.', 'A grand festival commemorating the sacrifice of Prophet Ibrahim. A festival associated with the Hajj pilgrimage.', 'தொழுகை நடத்துதல். குர்பானி (பலி) கொடுத்தல். இறைச்சியை ஏழைகளுக்கு பகிர்தல். உறவினர்களை சந்தித்தல்.', 'Performing prayers. Offering Qurbani (sacrifice). Sharing meat with the poor. Meeting relatives.', 'secular', 'Tamil Nadu');

-- Milad-un-Nabi
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('மீலாது நபி', 'Milad-un-Nabi', '-', 'இஸ்லாமிய நாட்காட்டி அடிப்படையில்', 1, 'நபிகள் நாயகம் முகமது பிறந்தநாள். இஸ்லாமிய சமூகத்தினரால் பக்தியுடன் கொண்டாடப்படும் விழா.', 'Birthday of Prophet Muhammad. A festival celebrated with devotion by the Islamic community.', 'சிறப்பு தொழுகை. நபிகள் நாயகத்தின் வாழ்க்கை வரலாறு படித்தல். இனிப்புகள் பகிர்தல். ஏழைகளுக்கு உணவு வழங்குதல்.', 'Special prayers. Reading the life history of the Prophet. Sharing sweets. Providing food to the poor.', 'secular', 'Tamil Nadu');

-- Christmas
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('கிறிஸ்துமஸ்', 'Christmas', 'மார்கழி', 'December', 1, 'இயேசு கிறிஸ்துவின் பிறந்தநாள். கிறிஸ்தவ சமூகத்தின் மிக முக்கியமான விழா. டிசம்பர் 25 அன்று உலகம் முழுவதும் கொண்டாடப்படுகிறது.', 'Birthday of Jesus Christ. The most important festival of the Christian community. Celebrated worldwide on December 25th.', 'தேவாலய வழிபாடு. கிறிஸ்துமஸ் மரம் அலங்கரித்தல். பரிசுகள் பரிமாறுதல். கேக் வெட்டுதல். குடும்பத்துடன் விருந்து.', 'Church worship. Decorating Christmas tree. Exchanging gifts. Cutting cake. Family feast.', 'secular', 'Tamil Nadu');

-- Easter
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஈஸ்டர்', 'Easter', 'பங்குனி/சித்திரை', 'March-April', 1, 'இயேசு கிறிஸ்து உயிர்த்தெழுந்த நாள். கிறிஸ்தவ சமூகத்தின் மிகவும் புனிதமான விழா.', 'The day of the resurrection of Jesus Christ. The most sacred festival of the Christian community.', 'தேவாலய சிறப்பு வழிபாடு. ஈஸ்டர் முட்டைகள் பகிர்தல். குடும்ப விருந்து. இசை மற்றும் பாடல்கள்.', 'Special church worship. Sharing Easter eggs. Family feast. Music and hymns.', 'secular', 'Tamil Nadu');

-- Thai Amavasai
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('தை அமாவாசை', 'Thai Amavasai', 'தை', 'January-February', 1, 'தை மாத அமாவாசையில் முன்னோர்களுக்கு நன்றி செலுத்தும் நாள். ராமேஸ்வரம் மற்றும் கடலோர நகரங்களில் சிறப்பாக கொண்டாடப்படுகிறது.', 'A day to honor ancestors on the new moon day of the Tamil month Thai. Celebrated especially in Rameswaram and coastal towns.', 'கடல் அல்லது ஆற்றில் புனித நீராடல். தர்ப்பணம் செய்தல். முன்னோர்களுக்கு பூஜை செய்தல்.', 'Sacred bath in the sea or river. Performing tharpanam. Performing puja for ancestors.', 'religious', 'Tamil Nadu');

-- Chitra Pournami
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('சித்ரா பௌர்ணமி', 'Chitra Pournami', 'சித்திரை', 'April-May', 1, 'சித்திரை மாத முழுநிலவு நாள். சித்ரகுப்தனை வழிபடும் நாள். கர்ம வினைகளை நீக்கும் புனிதமான நாள் என்று நம்பப்படுகிறது.', 'The full moon day of the Tamil month Chithirai. A day to worship Chitragupta. Believed to be a sacred day that removes karmic debts.', 'சித்ரகுப்தன் வழிபாடு செய்தல். புனித நீராடல். விளக்கு ஏற்றுதல். நல்ல செயல்கள் செய்தல்.', 'Worshipping Chitragupta. Sacred bathing. Lighting lamps. Performing good deeds.', 'religious', 'Tamil Nadu');

-- Aavani Avittam
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஆவணி அவிட்டம்', 'Aavani Avittam (Upakarma)', 'ஆவணி', 'August', 1, 'புதிய பூணூலை அணியும் நாள். வேதம் கற்கத் தொடங்கும் நாள். பிராமண சமூகத்தின் முக்கிய விழா.', 'The day of wearing a new sacred thread. The day to begin Vedic studies. An important festival of the Brahmin community.', 'பழைய பூணூலை மாற்றி புதிய பூணூல் அணிதல். ஹோமம் செய்தல். காயத்ரி ஜெபம் செய்தல்.', 'Changing the old sacred thread and wearing a new one. Performing homam. Chanting Gayatri mantra.', 'religious', 'Tamil Nadu');

-- Guru Purnima
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('குரு பூர்ணிமா', 'Guru Purnima', 'ஆடி', 'July', 1, 'குருவுக்கு நன்றி செலுத்தும் நாள். வியாசரின் பிறந்தநாள் என்றும் அழைக்கப்படுகிறது. ஆசிரியர்கள் மற்றும் வழிகாட்டிகளை மதிக்கும் நாள்.', 'A day to express gratitude to the Guru (teacher). Also called Vyasa Purnima. A day to honor teachers and mentors.', 'குருவுக்கு நன்றி தெரிவித்தல். குரு பூஜை செய்தல். ஆன்மிக நூல்கள் படித்தல்.', 'Expressing gratitude to the Guru. Performing Guru Puja. Reading spiritual texts.', 'religious', 'Tamil Nadu');

-- Adipura
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஆடிப்பூரம்', 'Aadi Pooram', 'ஆடி', 'July-August', 1, 'ஆண்டாள் நாச்சியார் பிறந்தநாள். ஸ்ரீவில்லிப்புத்தூரில் மிகச் சிறப்பாக கொண்டாடப்படுகிறது. வைணவ மரபின் முக்கிய விழா.', 'Birthday of Andal Nachiyar. Celebrated most grandly at Srivilliputhur. An important festival of the Vaishnava tradition.', 'ஆண்டாள் கோவிலில் சிறப்பு வழிபாடு. தேர் திருவிழா. திருப்பாவை பாடுதல்.', 'Special worship at Andal temple. Chariot festival. Singing Thiruppavai.', 'religious', 'Tamil Nadu');

-- Navarathri Golu
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('கொலு வைப்பு', 'Golu (Navarathri Doll Display)', 'புரட்டாசி', 'September-October', 9, 'நவராத்திரி காலத்தில் படிகளில் பொம்மைகள் அடுக்கி வைக்கும் தமிழ் மரபு. பெண்கள் வீட்டுக்கு வீடு சென்று கொலு பார்க்கும் பாரம்பரியம்.', 'The Tamil tradition of arranging dolls on steps during Navaratri. The tradition of women visiting each other''s homes to see the Golu displays.', 'ஒற்றைப்படை படிகளில் (7, 9, 11) பொம்மைகள் அடுக்குதல். சுண்டல், இனிப்பு விநியோகித்தல். மாலையில் பாடல் நிகழ்ச்சி நடத்துதல்.', 'Arranging dolls on odd-numbered steps (7, 9, 11). Distributing sundal and sweets. Conducting evening music events.', 'cultural', 'Tamil Nadu');

-- Hanuman Jayanti
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஹனுமான் ஜெயந்தி', 'Hanuman Jayanti', 'மார்கழி/பங்குனி', 'December/March-April', 1, 'அனுமனின் பிறந்தநாள். பக்தி, வீரம், பணிவின் அடையாளமான அனுமனை வழிபடும் நாள்.', 'Birthday of Lord Hanuman. A day to worship Hanuman, the symbol of devotion, bravery, and humility.', 'அனுமன் கோவிலில் வழிபாடு. சுந்தரகாண்டம் படித்தல். வடை மாலை சூட்டுதல்.', 'Worship at Hanuman temple. Reading Sundara Kandam. Offering vadai garland.', 'religious', 'Tamil Nadu');

-- Ratha Saptami
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ரத சப்தமி', 'Ratha Saptami', 'தை', 'January-February', 1, 'சூரிய பகவானின் பிறந்தநாள் என்று கருதப்படுகிறது. சூரியன் தனது தேரில் வடக்கு நோக்கி பயணிக்கத் தொடங்கும் நாள்.', 'Considered the birthday of the Sun God. The day the Sun begins his northward journey in his chariot.', 'சூரிய வழிபாடு செய்தல். புனித நீராடல். எருக்கம் இலைகள் வைத்து வழிபாடு.', 'Worshipping the Sun God. Sacred bathing. Worship with Erukku (Calotropis) leaves.', 'religious', 'Tamil Nadu');

-- Puthuvarusha Pirappu
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('பொருநை விழா', 'Porunai Festival (Thamirabarani Festival)', 'ஆடி', 'July-August', 3, 'தாமிரபரணி ஆற்றின் வெள்ளத்தை கொண்டாடும் விழா. நெல்லை மாவட்டத்தின் முக்கிய விழா. ஆடிப்பெருக்குடன் தொடர்புடையது.', 'A festival celebrating the flooding of the Thamirabarani river. An important festival of Tirunelveli district. Associated with Aadi Perukku.', 'தாமிரபரணி ஆற்றங்கரையில் வழிபாடு. நீராடல். விளக்கு ஏற்றி ஆற்றில் விடுதல்.', 'Worship on the banks of the Thamirabarani. Bathing. Lighting lamps and releasing them on the river.', 'harvest', 'திருநெல்வேலி, Tamil Nadu');

-- Naga Chaturthi / Naga Panchami
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('நாகர் சதுர்த்தி / நாகபஞ்சமி', 'Naga Chaturthi / Naga Panchami', 'ஆடி/ஆவணி', 'July-August', 1, 'நாகர்களை வழிபடும் நாள். நாக தோஷம் நீக்கும் விழா. புற்று வழிபாடு செய்யப்படும் நாள்.', 'A day to worship serpent deities. A festival to remove Naga dosha. A day when anthills are worshipped.', 'நாகர் சிலைகளுக்கு பால் ஊற்றி வழிபடுதல். புற்றுக்கு பால் வைத்தல். நாகர் கோவிலில் வழிபாடு.', 'Pouring milk on serpent idols. Offering milk at anthills. Worship at Naga temples.', 'religious', 'Tamil Nadu');

-- Pongal Vizha (Jallikattu)
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('ஜல்லிக்கட்டு', 'Jallikattu', 'தை', 'January', 1, 'தமிழர்களின் பாரம்பரிய வீர விளையாட்டு. மாட்டுப்பொங்கல் அன்று நடத்தப்படும் காளை அடக்கும் கலை. அலங்காநல்லூர், பாலமேடு போன்ற இடங்களில் பிரபலம்.', 'The traditional sport of valor of the Tamils. The art of taming bulls conducted on Mattu Pongal day. Famous in places like Alanganallur and Palamedu.', 'காளைகளை அடக்குதல். வீரர்களுக்கு பரிசுகள் வழங்குதல். கிராம கொண்டாட்டங்கள்.', 'Taming bulls. Awarding prizes to victorious participants. Village celebrations.', 'cultural', 'மதுரை, சிவகங்கை, புதுக்கோட்டை, Tamil Nadu');

-- Muharram
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('முஹர்ரம்', 'Muharram', '-', 'இஸ்லாமிய நாட்காட்டி அடிப்படையில்', 10, 'இஸ்லாமிய புத்தாண்டின் முதல் மாதம். இமாம் ஹுசைனின் தியாகத்தை நினைவுகூரும் காலம்.', 'The first month of the Islamic New Year. A period commemorating the sacrifice of Imam Hussain.', 'துக்கம் அனுசரித்தல். சிறப்பு தொழுகை. ஏழைகளுக்கு உணவு வழங்குதல்.', 'Observing mourning. Special prayers. Providing food to the poor.', 'secular', 'Tamil Nadu');

-- Karadaiyan Nombu
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('கரடையான் நோன்பு', 'Karadaiyan Nombu', 'மாசி/பங்குனி', 'March', 1, 'சாவித்திரி தன் கணவன் சத்தியவானின் உயிரை எமனிடம் இருந்து மீட்ட நாள். திருமணமான பெண்கள் கணவனின் நீண்ட ஆயுளுக்காக நோன்பு இருக்கும் நாள்.', 'The day Savithri rescued her husband Satyavan''s life from Yama, the god of death. A day when married women fast for the long life of their husbands.', 'கரடை அடை (நோன்பு அடை) செய்தல். மஞ்சள் கயிறு (தாலி கயிறு) மாற்றுதல். நோன்பு இருத்தல்.', 'Making Karadai Adai (Nombu Adai). Changing the yellow thread (thali thread). Observing fast.', 'religious', 'Tamil Nadu');

-- Thiruvalluvar Day
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('திருவள்ளுவர் தினம்', 'Thiruvalluvar Day', 'தை', 'January', 1, 'திருக்குறள் இயற்றிய திருவள்ளுவரின் நினைவு நாள். தை மாதம் இரண்டாம் நாள் (ஜனவரி 16 அல்லது 17) கொண்டாடப்படுகிறது. தமிழ் இலக்கிய நாளாகவும் கொண்டாடப்படுகிறது.', 'Memorial day of Thiruvalluvar, the author of Thirukkural. Celebrated on the second day of Thai month (January 16 or 17). Also celebrated as Tamil Literature Day.', 'திருவள்ளுவர் சிலைகளுக்கு மாலை அணிவித்தல். திருக்குறள் ஓதுதல். கலை நிகழ்ச்சிகள் நடத்துதல்.', 'Garlanding Thiruvalluvar statues. Reciting Thirukkural verses. Conducting cultural programs.', 'cultural', 'Tamil Nadu');

-- Uzhavar Thirunal
INSERT INTO festivals (name_tamil, name_english, tamil_month, english_month, duration_days, significance_tamil, significance_english, rituals_tamil, rituals_english, type, region) VALUES
('உழவர் திருநாள்', 'Uzhavar Thirunal (Farmers Day)', 'தை', 'January', 1, 'உழவர்களை கௌரவிக்கும் நாள். தைப்பொங்கல் அன்று உழவர்களின் பங்களிப்பை நினைவுகூரும் நாள். விவசாயிகளுக்கு விருதுகள் வழங்கப்படும் நாள்.', 'A day to honor farmers. A day to commemorate the contribution of farmers on Thai Pongal. A day when awards are given to farmers.', 'விவசாயிகளுக்கு விருதுகள் வழங்குதல். விவசாய கண்காட்சிகள் நடத்துதல். உழவர்களை கௌரவித்தல்.', 'Awarding prizes to farmers. Conducting agricultural exhibitions. Honoring farmers.', 'harvest', 'Tamil Nadu');
