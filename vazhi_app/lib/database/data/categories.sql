-- Categories and Query Patterns Data
-- For routing queries to deterministic vs AI paths

-- Clear existing data
DELETE FROM categories;
DELETE FROM query_patterns;

-- Knowledge Categories
INSERT OR REPLACE INTO categories (id, name_tamil, name_english, icon, sort_order) VALUES
('thirukkural', 'திருக்குறள்', 'Thirukkural', '📜', 1),
('schemes', 'அரசு திட்டங்கள்', 'Government Schemes', '🏛️', 2),
('emergency', 'அவசர தொடர்பு', 'Emergency Contacts', '🚨', 3),
('health', 'மருத்துவமனைகள்', 'Hospitals', '🏥', 4),
('festivals', 'திருவிழாக்கள்', 'Festivals', '🎉', 5),
('siddhars', 'சித்தர்கள்', 'Siddhars', '🙏', 6),
('safety', 'பாதுகாப்பு', 'Safety & Scams', '🛡️', 7);

-- Query Patterns for Routing
-- Priority 100 = highest (exact match), 50 = medium, 10 = low (fallback)

-- Thirukkural patterns
INSERT OR REPLACE INTO query_patterns (pattern, category_id, priority, response_type) VALUES
('குறள் [0-9]+', 'thirukkural', 100, 'deterministic'),
('kural [0-9]+', 'thirukkural', 100, 'deterministic'),
('திருக்குறள் [0-9]+', 'thirukkural', 100, 'deterministic'),
('thirukkural [0-9]+', 'thirukkural', 100, 'deterministic'),
('அதிகாரம்', 'thirukkural', 80, 'deterministic'),
('athikaram', 'thirukkural', 80, 'deterministic'),
('வள்ளுவர்', 'thirukkural', 60, 'hybrid'),
('valluvar', 'thirukkural', 60, 'hybrid'),
('குறள்', 'thirukkural', 50, 'deterministic'),
('kural', 'thirukkural', 50, 'deterministic');

-- Emergency patterns
INSERT OR REPLACE INTO query_patterns (pattern, category_id, priority, response_type) VALUES
('அவசர', 'emergency', 100, 'deterministic'),
('emergency', 'emergency', 100, 'deterministic'),
('ஆம்புலன்ஸ்', 'emergency', 100, 'deterministic'),
('ambulance', 'emergency', 100, 'deterministic'),
('போலீஸ்', 'emergency', 100, 'deterministic'),
('police', 'emergency', 100, 'deterministic'),
('தீ', 'emergency', 90, 'deterministic'),
('fire', 'emergency', 90, 'deterministic'),
('108', 'emergency', 100, 'deterministic'),
('100', 'emergency', 100, 'deterministic'),
('helpline', 'emergency', 80, 'deterministic'),
('உதவி எண்', 'emergency', 80, 'deterministic');

-- Schemes patterns
INSERT OR REPLACE INTO query_patterns (pattern, category_id, priority, response_type) VALUES
('திட்டம்', 'schemes', 80, 'deterministic'),
('scheme', 'schemes', 80, 'deterministic'),
('CMCHIS', 'schemes', 100, 'deterministic'),
('மருத்துவ காப்பீடு', 'schemes', 90, 'deterministic'),
('ஆயுஷ்மான்', 'schemes', 100, 'deterministic'),
('ayushman', 'schemes', 100, 'deterministic'),
('முத்ரா', 'schemes', 100, 'deterministic'),
('mudra', 'schemes', 100, 'deterministic'),
('கிசான்', 'schemes', 100, 'deterministic'),
('kisan', 'schemes', 100, 'deterministic'),
('ஓய்வூதியம்', 'schemes', 90, 'deterministic'),
('pension', 'schemes', 90, 'deterministic'),
('மகளிர் உரிமை', 'schemes', 100, 'deterministic'),
('சலுகை', 'schemes', 70, 'hybrid'),
('subsidies', 'schemes', 70, 'hybrid'),
('அரசு உதவி', 'schemes', 70, 'hybrid');

-- Health patterns
INSERT OR REPLACE INTO query_patterns (pattern, category_id, priority, response_type) VALUES
('மருத்துவமனை', 'health', 90, 'deterministic'),
('hospital', 'health', 90, 'deterministic'),
('doctor', 'health', 70, 'hybrid'),
('மருத்துவர்', 'health', 70, 'hybrid'),
('clinic', 'health', 70, 'hybrid'),
('PHC', 'health', 90, 'deterministic'),
('ஆரம்ப சுகாதார', 'health', 90, 'deterministic'),
('அரசு மருத்துவமனை', 'health', 100, 'deterministic');

-- Scam/Safety patterns
INSERT OR REPLACE INTO query_patterns (pattern, category_id, priority, response_type) VALUES
('மோசடி', 'safety', 90, 'deterministic'),
('scam', 'safety', 90, 'deterministic'),
('fraud', 'safety', 90, 'deterministic'),
('ஏமாற்று', 'safety', 90, 'deterministic'),
('OTP', 'safety', 100, 'deterministic'),
('வங்கி மோசடி', 'safety', 100, 'deterministic'),
('bank fraud', 'safety', 100, 'deterministic'),
('பாதுகாப்பு', 'safety', 70, 'hybrid');
