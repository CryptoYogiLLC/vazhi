-- Emergency Contacts Data
-- National and Tamil Nadu emergency numbers

-- National Emergency Numbers
INSERT OR REPLACE INTO emergency_contacts (name_tamil, name_english, phone, alternate_phone, type, district, is_national) VALUES
('காவல் துறை', 'Police', '100', NULL, 'police', NULL, 1),
('தீயணைப்பு', 'Fire', '101', NULL, 'fire', NULL, 1),
('அவசர மருத்துவம்', 'Ambulance', '108', '102', 'medical', NULL, 1),
('பெண்கள் உதவி எண்', 'Women Helpline', '181', '1091', 'women', NULL, 1),
('குழந்தைகள் உதவி எண்', 'Child Helpline', '1098', NULL, 'child', NULL, 1),
('பேரிடர் மேலாண்மை', 'Disaster Management', '1070', NULL, 'disaster', NULL, 1),
('ஒருங்கிணைந்த அவசர எண்', 'Emergency (All)', '112', NULL, 'medical', NULL, 1),
('COVID-19 உதவி எண்', 'COVID-19 Helpline', '1075', NULL, 'medical', NULL, 1),
('மூத்த குடிமக்கள் உதவி', 'Senior Citizen Helpline', '14567', NULL, 'other', NULL, 1),
('சைபர் குற்றம்', 'Cyber Crime', '1930', NULL, 'police', NULL, 1),
('ரயில்வே உதவி', 'Railway Helpline', '139', NULL, 'other', NULL, 1),
('சாலை விபத்து', 'Road Accident', '1073', NULL, 'medical', NULL, 1),
('LPG அவசரநிலை', 'LPG Emergency', '1906', NULL, 'fire', NULL, 1),
('விஷம் தகவல்', 'Poison Information', '1800-116-117', NULL, 'medical', NULL, 1),
('மனநல உதவி', 'Mental Health Helpline', '08046110007', NULL, 'medical', NULL, 1),
('AIDS உதவி', 'AIDS Helpline', '1097', NULL, 'medical', NULL, 1),
('இரத்த வங்கி', 'Blood Bank', '104', NULL, 'medical', NULL, 1),
('மின்சாரம் புகார்', 'Electricity Complaint', '1912', NULL, 'other', NULL, 1),
('குடிநீர் புகார்', 'Water Supply Complaint', '1916', NULL, 'other', NULL, 1);

-- Tamil Nadu Specific Numbers
INSERT OR REPLACE INTO emergency_contacts (name_tamil, name_english, phone, alternate_phone, type, district, is_national) VALUES
('TN காவல் கட்டுப்பாட்டு அறை', 'TN Police Control Room', '044-23452365', NULL, 'police', NULL, 0),
('CMCHIS உதவி எண்', 'CMCHIS Helpline', '104', '1800-599-5960', 'medical', NULL, 0),
('TN அரசு ஆம்புலன்ஸ்', 'TN Govt Ambulance (108)', '108', NULL, 'medical', NULL, 0),
('TN மின்வாரியம்', 'TNEB Helpline', '94987-94987', NULL, 'other', NULL, 0),
('சென்னை போக்குவரத்து காவல்', 'Chennai Traffic Police', '103', NULL, 'police', 'Chennai', 0),
('சென்னை மாநகராட்சி', 'Chennai Corporation', '1913', NULL, 'other', 'Chennai', 0),
('TN நுகர்வோர் புகார்', 'TN Consumer Helpline', '1800-425-1082', NULL, 'other', NULL, 0),
('அரசு மருத்துவமனை சென்னை', 'Govt General Hospital Chennai', '044-25305000', NULL, 'medical', 'Chennai', 0),
('JIPMER புதுச்சேரி', 'JIPMER Puducherry', '0413-2272380', NULL, 'medical', NULL, 0),
('CMC வேலூர்', 'CMC Vellore', '0416-2281000', NULL, 'medical', 'Vellore', 0);
