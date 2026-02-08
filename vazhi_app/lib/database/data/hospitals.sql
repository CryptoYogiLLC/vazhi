-- Hospitals Data
-- Major government and private hospitals in Tamil Nadu

-- Clear existing data
DELETE FROM hospitals;

-- Chennai Government Hospitals
INSERT OR REPLACE INTO hospitals (name_tamil, name_english, type, district, city, address, phone, emergency_phone, has_emergency, has_ambulance, accepts_cmchis, accepts_ayushman) VALUES
('ராஜீவ் காந்தி அரசு பொது மருத்துவமனை', 'Rajiv Gandhi Government General Hospital', 'ghq', 'Chennai', 'Chennai', 'Park Town, Chennai - 600003', '044-25305000', '044-25305000', 1, 1, 1, 1),
('கிலிபாக் அரசு மருத்துவமனை', 'Kilpauk Medical College Hospital', 'govt', 'Chennai', 'Chennai', 'Kilpauk, Chennai - 600010', '044-26432902', '044-26432902', 1, 1, 1, 1),
('ஸ்டான்லி அரசு மருத்துவமனை', 'Stanley Medical College Hospital', 'govt', 'Chennai', 'Chennai', 'Old Jail Road, Royapuram, Chennai', '044-25281351', '044-25281351', 1, 1, 1, 1),
('எழும்பூர் குழந்தைகள் மருத்துவமனை', 'Institute of Child Health Egmore', 'govt', 'Chennai', 'Chennai', 'Egmore, Chennai - 600008', '044-28190100', '044-28190100', 1, 1, 1, 1),
('ஓமந்தூரார் அரசு மருத்துவமனை', 'Omandurar Government Estate Hospital', 'govt', 'Chennai', 'Chennai', 'Wallajah Road, Chennai - 600002', '044-25360500', '044-25360500', 1, 1, 1, 1);

-- Other District Government Hospitals
INSERT OR REPLACE INTO hospitals (name_tamil, name_english, type, district, city, address, phone, emergency_phone, has_emergency, has_ambulance, accepts_cmchis, accepts_ayushman) VALUES
('மதுரை அரசு ராஜாஜி மருத்துவமனை', 'Government Rajaji Hospital Madurai', 'ghq', 'Madurai', 'Madurai', 'Alagar Koil Road, Madurai', '0452-2532535', '108', 1, 1, 1, 1),
('கோவை அரசு மருத்துவமனை', 'Coimbatore Government Medical College', 'ghq', 'Coimbatore', 'Coimbatore', 'Avinashi Road, Coimbatore', '0422-2301393', '108', 1, 1, 1, 1),
('திருச்சி அரசு மருத்துவமனை', 'Trichy Government Hospital', 'ghq', 'Tiruchirappalli', 'Trichy', 'Mahatma Gandhi Memorial, Trichy', '0431-2414969', '108', 1, 1, 1, 1),
('சேலம் அரசு மருத்துவமனை', 'Salem Government Hospital', 'ghq', 'Salem', 'Salem', 'Cuddalore Main Road, Salem', '0427-2212222', '108', 1, 1, 1, 1),
('திருநெல்வேலி அரசு மருத்துவமனை', 'Tirunelveli Government Medical College', 'ghq', 'Tirunelveli', 'Tirunelveli', 'High Ground Road, Tirunelveli', '0462-2572736', '108', 1, 1, 1, 1),
('வேலூர் CMC மருத்துவமனை', 'CMC Vellore', 'private', 'Vellore', 'Vellore', 'Ida Scudder Road, Vellore', '0416-2281000', '0416-2282100', 1, 1, 1, 1),
('தஞ்சாவூர் அரசு மருத்துவமனை', 'Thanjavur Medical College Hospital', 'ghq', 'Thanjavur', 'Thanjavur', 'Medical College Road, Thanjavur', '04362-231831', '108', 1, 1, 1, 1),
('ஈரோடு அரசு மருத்துவமனை', 'Erode Government Hospital', 'govt', 'Erode', 'Erode', 'Perundurai Road, Erode', '0424-2256260', '108', 1, 1, 1, 1),
('திருப்பூர் அரசு மருத்துவமனை', 'Tiruppur Government Hospital', 'govt', 'Tiruppur', 'Tiruppur', 'Avinashi Road, Tiruppur', '0421-2236262', '108', 1, 1, 1, 1),
('நாகர்கோவில் அரசு மருத்துவமனை', 'Kanyakumari Government Medical College', 'ghq', 'Kanyakumari', 'Nagercoil', 'Asaripallam, Nagercoil', '04652-232321', '108', 1, 1, 1, 1);

-- Major Private Hospitals
INSERT OR REPLACE INTO hospitals (name_tamil, name_english, type, specialty, district, city, phone, has_emergency, has_ambulance, accepts_cmchis, accepts_ayushman) VALUES
('அப்போலோ மருத்துவமனை சென்னை', 'Apollo Hospital Chennai', 'private', 'Multi-specialty', 'Chennai', 'Chennai', '044-28290200', 1, 1, 0, 0),
('MIOT மருத்துவமனை', 'MIOT Hospital', 'private', 'Orthopaedics', 'Chennai', 'Chennai', '044-42002288', 1, 1, 0, 0),
('ஃபோர்டிஸ் மலர் மருத்துவமனை', 'Fortis Malar Hospital', 'private', 'Cardiac', 'Chennai', 'Chennai', '044-42892222', 1, 1, 0, 0),
('காவேரி மருத்துவமனை', 'Kauvery Hospital', 'private', 'Multi-specialty', 'Chennai', 'Chennai', '044-40006000', 1, 1, 1, 1),
('SRM மருத்துவமனை', 'SRM Hospital', 'private', 'Multi-specialty', 'Kanchipuram', 'Kattankulathur', '044-27452590', 1, 1, 1, 1),
('PSG மருத்துவமனை கோவை', 'PSG Hospital Coimbatore', 'private', 'Multi-specialty', 'Coimbatore', 'Coimbatore', '0422-2570170', 1, 1, 1, 1),
('அரவிந்த் கண் மருத்துவமனை மதுரை', 'Aravind Eye Hospital Madurai', 'private', 'Ophthalmology', 'Madurai', 'Madurai', '0452-4356100', 1, 0, 1, 1),
('மீனாட்சி மிஷன் மருத்துவமனை', 'Meenakshi Mission Hospital', 'private', 'Multi-specialty', 'Madurai', 'Madurai', '0452-2588741', 1, 1, 1, 1),
('GKNM மருத்துவமனை கோவை', 'GKNM Hospital Coimbatore', 'private', 'Multi-specialty', 'Coimbatore', 'Coimbatore', '0422-2214444', 1, 1, 1, 1),
('KG மருத்துவமனை கோவை', 'KG Hospital Coimbatore', 'private', 'Multi-specialty', 'Coimbatore', 'Coimbatore', '0422-2222424', 1, 1, 1, 1);
