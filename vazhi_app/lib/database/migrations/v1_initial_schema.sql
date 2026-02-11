-- VAZHI Knowledge Database Schema v1
-- Initial schema for hybrid retrieval architecture

-- ============================================================================
-- COMMON TABLES
-- ============================================================================

-- Categories: Master table for organizing all content by knowledge pack
CREATE TABLE IF NOT EXISTS categories (
    id              TEXT PRIMARY KEY,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,
    description     TEXT,
    icon            TEXT,
    color           TEXT,
    sort_order      INTEGER DEFAULT 0,
    created_at      TEXT DEFAULT (datetime('now')),
    updated_at      TEXT DEFAULT (datetime('now'))
);

-- Query Patterns: For routing queries to deterministic vs AI path
CREATE TABLE IF NOT EXISTS query_patterns (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern         TEXT NOT NULL,
    category_id     TEXT NOT NULL,
    priority        INTEGER DEFAULT 0,
    response_type   TEXT NOT NULL CHECK (response_type IN ('deterministic', 'ai', 'hybrid'))
);

CREATE INDEX IF NOT EXISTS idx_pattern_priority ON query_patterns(priority DESC);

-- ============================================================================
-- CULTURE PACK
-- ============================================================================

-- Thirukkural: All 1,330 verses with metadata
CREATE TABLE IF NOT EXISTS thirukkural (
    kural_number        INTEGER PRIMARY KEY,
    verse_line1         TEXT NOT NULL,
    verse_line2         TEXT NOT NULL,
    verse_full          TEXT NOT NULL,
    paal                TEXT NOT NULL,
    paal_english        TEXT NOT NULL,
    iyal                TEXT,
    athikaram           TEXT NOT NULL,
    athikaram_english   TEXT NOT NULL,
    athikaram_number    INTEGER NOT NULL,
    meaning_tamil       TEXT,
    meaning_english     TEXT,
    keywords_tamil      TEXT,
    keywords_english    TEXT
);

CREATE INDEX IF NOT EXISTS idx_kural_athikaram ON thirukkural(athikaram_number);
CREATE INDEX IF NOT EXISTS idx_kural_paal ON thirukkural(paal);

-- Siddhars: Information about the 18 Siddhars
CREATE TABLE IF NOT EXISTS siddhars (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,
    period          TEXT,
    birthplace      TEXT,
    famous_work     TEXT,
    work_english    TEXT,
    expertise       TEXT,
    brief_tamil     TEXT NOT NULL,
    brief_english   TEXT NOT NULL,
    teachings       TEXT,
    image_asset     TEXT
);

-- Festivals: Tamil and Hindu festivals
CREATE TABLE IF NOT EXISTS festivals (
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,
    name_tamil              TEXT NOT NULL,
    name_english            TEXT NOT NULL,
    tamil_month             TEXT,
    english_month           TEXT,
    duration_days           INTEGER DEFAULT 1,
    significance_tamil      TEXT NOT NULL,
    significance_english    TEXT NOT NULL,
    rituals_tamil           TEXT,
    rituals_english         TEXT,
    type                    TEXT,
    region                  TEXT DEFAULT 'Tamil Nadu'
);

-- ============================================================================
-- GOVERNMENT PACK
-- ============================================================================

-- Schemes: Government welfare schemes
CREATE TABLE IF NOT EXISTS schemes (
    id                      TEXT PRIMARY KEY,
    name_tamil              TEXT NOT NULL,
    name_english            TEXT NOT NULL,
    level                   TEXT NOT NULL CHECK (level IN ('central', 'state', 'district')),
    department              TEXT,
    description_tamil       TEXT NOT NULL,
    description_english     TEXT NOT NULL,
    benefit_type            TEXT,
    benefit_amount          TEXT,
    how_to_apply_tamil      TEXT,
    how_to_apply_english    TEXT,
    application_url         TEXT,
    is_active               INTEGER DEFAULT 1,
    last_updated            TEXT,
    created_at              TEXT DEFAULT (datetime('now')),
    updated_at              TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_schemes_level ON schemes(level);
CREATE INDEX IF NOT EXISTS idx_schemes_active ON schemes(is_active);

-- Scheme Eligibility: Eligibility criteria for schemes
CREATE TABLE IF NOT EXISTS scheme_eligibility (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    scheme_id       TEXT NOT NULL,
    criteria_type   TEXT NOT NULL,
    criteria_tamil  TEXT NOT NULL,
    criteria_english TEXT NOT NULL,
    min_value       TEXT,
    max_value       TEXT,
    allowed_values  TEXT,
    FOREIGN KEY (scheme_id) REFERENCES schemes(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_eligibility_scheme ON scheme_eligibility(scheme_id);

-- Scheme Documents: Required documents for scheme applications
CREATE TABLE IF NOT EXISTS scheme_documents (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    scheme_id       TEXT NOT NULL,
    document_tamil  TEXT NOT NULL,
    document_english TEXT NOT NULL,
    is_mandatory    INTEGER DEFAULT 1,
    notes           TEXT,
    FOREIGN KEY (scheme_id) REFERENCES schemes(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_documents_scheme ON scheme_documents(scheme_id);

-- Government Offices: Government office contacts
CREATE TABLE IF NOT EXISTS govt_offices (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,
    district        TEXT,
    address         TEXT,
    pincode         TEXT,
    phone           TEXT,
    email           TEXT,
    website         TEXT,
    working_hours   TEXT,
    holidays        TEXT,
    office_type     TEXT,
    department      TEXT
);

CREATE INDEX IF NOT EXISTS idx_offices_district ON govt_offices(district);
CREATE INDEX IF NOT EXISTS idx_offices_type ON govt_offices(office_type);

-- ============================================================================
-- EDUCATION PACK
-- ============================================================================

-- Scholarships: Available scholarships
CREATE TABLE IF NOT EXISTS scholarships (
    id                  TEXT PRIMARY KEY,
    name_tamil          TEXT NOT NULL,
    name_english        TEXT NOT NULL,
    provider            TEXT,
    department          TEXT,
    description_tamil   TEXT,
    description_english TEXT,
    amount              TEXT,
    education_level     TEXT,
    category            TEXT,
    income_limit        TEXT,
    application_start   TEXT,
    application_end     TEXT,
    apply_url           TEXT,
    is_active           INTEGER DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_scholarships_level ON scholarships(education_level);
CREATE INDEX IF NOT EXISTS idx_scholarships_category ON scholarships(category);

-- Institutions: Educational institutions directory
CREATE TABLE IF NOT EXISTS institutions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name_tamil      TEXT,
    name_english    TEXT NOT NULL,
    type            TEXT NOT NULL,
    board           TEXT,
    district        TEXT,
    city            TEXT,
    address         TEXT,
    pincode         TEXT,
    phone           TEXT,
    email           TEXT,
    website         TEXT,
    courses         TEXT,
    accreditation   TEXT,
    established     INTEGER
);

CREATE INDEX IF NOT EXISTS idx_inst_district ON institutions(district);
CREATE INDEX IF NOT EXISTS idx_inst_type ON institutions(type);

-- Exams: Competitive and entrance exams
CREATE TABLE IF NOT EXISTS exams (
    id                  TEXT PRIMARY KEY,
    name_tamil          TEXT,
    name_english        TEXT NOT NULL,
    conducting_body     TEXT,
    level               TEXT,
    eligibility_tamil   TEXT,
    eligibility_english TEXT,
    exam_pattern        TEXT,
    syllabus_url        TEXT,
    official_site       TEXT,
    application_start   TEXT,
    application_end     TEXT,
    exam_date           TEXT,
    result_date         TEXT
);

-- ============================================================================
-- LEGAL PACK
-- ============================================================================

-- Legal Templates: Templates for legal documents
CREATE TABLE IF NOT EXISTS legal_templates (
    id                      TEXT PRIMARY KEY,
    name_tamil              TEXT NOT NULL,
    name_english            TEXT NOT NULL,
    category                TEXT,
    template_tamil          TEXT NOT NULL,
    template_english        TEXT,
    instructions_tamil      TEXT,
    instructions_english    TEXT,
    submit_to               TEXT,
    submit_address          TEXT,
    fees                    TEXT
);

CREATE INDEX IF NOT EXISTS idx_templates_category ON legal_templates(category);

-- Legal Rights: Citizen rights information
CREATE TABLE IF NOT EXISTS legal_rights (
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,
    title_tamil             TEXT NOT NULL,
    title_english           TEXT NOT NULL,
    description_tamil       TEXT NOT NULL,
    description_english     TEXT NOT NULL,
    act_name                TEXT,
    section                 TEXT,
    category                TEXT,
    how_to_claim_tamil      TEXT,
    how_to_claim_english    TEXT
);

CREATE INDEX IF NOT EXISTS idx_rights_category ON legal_rights(category);

-- ============================================================================
-- HEALTHCARE PACK
-- ============================================================================

-- Hospitals: Hospital and health facility directory
CREATE TABLE IF NOT EXISTS hospitals (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name_tamil      TEXT,
    name_english    TEXT NOT NULL,
    type            TEXT NOT NULL,
    specialty       TEXT,
    district        TEXT NOT NULL,
    city            TEXT,
    address         TEXT,
    pincode         TEXT,
    latitude        REAL,
    longitude       REAL,
    phone           TEXT,
    emergency_phone TEXT,
    email           TEXT,
    beds            INTEGER,
    has_emergency   INTEGER DEFAULT 0,
    has_ambulance   INTEGER DEFAULT 0,
    accepts_cmchis  INTEGER DEFAULT 0,
    accepts_ayushman INTEGER DEFAULT 0,
    created_at      TEXT DEFAULT (datetime('now')),
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_hosp_district ON hospitals(district);
CREATE INDEX IF NOT EXISTS idx_hosp_type ON hospitals(type);
CREATE INDEX IF NOT EXISTS idx_hosp_cmchis ON hospitals(accepts_cmchis);

-- Siddha Medicine: Siddha remedies and practices
CREATE TABLE IF NOT EXISTS siddha_medicine (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    name_tamil          TEXT NOT NULL,
    name_english        TEXT,
    category            TEXT,
    description_tamil   TEXT NOT NULL,
    description_english TEXT,
    traditional_use     TEXT,
    preparation         TEXT,
    disclaimer          TEXT DEFAULT 'இது பொதுவான தகவல் மட்டுமே. மருத்துவரை அணுகவும்.'
);

CREATE INDEX IF NOT EXISTS idx_siddha_category ON siddha_medicine(category);

-- Emergency Contacts: Emergency service contacts
CREATE TABLE IF NOT EXISTS emergency_contacts (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,
    phone           TEXT NOT NULL,
    alternate_phone TEXT,
    type            TEXT NOT NULL,
    district        TEXT,
    is_national     INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_emergency_type ON emergency_contacts(type);

-- ============================================================================
-- SECURITY PACK
-- ============================================================================

-- Scam Patterns: Known scam patterns for detection
CREATE TABLE IF NOT EXISTS scam_patterns (
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,
    name_tamil              TEXT NOT NULL,
    name_english            TEXT NOT NULL,
    type                    TEXT NOT NULL,
    description_tamil       TEXT NOT NULL,
    description_english     TEXT NOT NULL,
    red_flags_tamil         TEXT NOT NULL,
    red_flags_english       TEXT NOT NULL,
    example_messages        TEXT,
    prevention_tamil        TEXT,
    prevention_english      TEXT,
    report_to               TEXT,
    report_number           TEXT,
    created_at              TEXT DEFAULT (datetime('now')),
    updated_at              TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_scam_type ON scam_patterns(type);

-- Cyber Safety Tips: Cyber safety guidelines
CREATE TABLE IF NOT EXISTS cyber_safety_tips (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    title_tamil     TEXT NOT NULL,
    title_english   TEXT NOT NULL,
    tip_tamil       TEXT NOT NULL,
    tip_english     TEXT NOT NULL,
    category        TEXT,
    priority        INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_safety_category ON cyber_safety_tips(category);
CREATE INDEX IF NOT EXISTS idx_safety_priority ON cyber_safety_tips(priority DESC);

-- ============================================================================
-- FULL-TEXT SEARCH (FTS5)
-- ============================================================================

-- Search Index: Full-text search across all content
CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
    content_id,
    content_type,
    category_id,
    title_tamil,
    title_english,
    content_tamil,
    content_english,
    keywords,
    tokenize='unicode61'
);

-- ============================================================================
-- FTS5 AUTO-POPULATION TRIGGERS
-- ============================================================================

-- Trigger: Auto-populate search_index when Thirukkural is inserted
CREATE TRIGGER IF NOT EXISTS fts_thirukkural_insert AFTER INSERT ON thirukkural
BEGIN
    INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
    VALUES (
        NEW.kural_number,
        'thirukkural',
        'culture',
        NEW.athikaram || ' - குறள் ' || NEW.kural_number,
        NEW.athikaram_english || ' - Kural ' || NEW.kural_number,
        NEW.verse_full || ' ' || COALESCE(NEW.meaning_tamil, ''),
        COALESCE(NEW.meaning_english, ''),
        COALESCE(NEW.keywords_tamil, '') || ' ' || COALESCE(NEW.keywords_english, '')
    );
END;

-- Trigger: Auto-populate search_index when schemes are inserted
CREATE TRIGGER IF NOT EXISTS fts_schemes_insert AFTER INSERT ON schemes
BEGIN
    INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
    VALUES (
        NEW.id,
        'scheme',
        'govt',
        NEW.name_tamil,
        NEW.name_english,
        NEW.description_tamil || ' ' || COALESCE(NEW.how_to_apply_tamil, ''),
        NEW.description_english || ' ' || COALESCE(NEW.how_to_apply_english, ''),
        COALESCE(NEW.department, '') || ' ' || COALESCE(NEW.benefit_type, '')
    );
END;

-- Trigger: Auto-populate search_index when hospitals are inserted
CREATE TRIGGER IF NOT EXISTS fts_hospitals_insert AFTER INSERT ON hospitals
BEGIN
    INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
    VALUES (
        NEW.id,
        'hospital',
        'health',
        COALESCE(NEW.name_tamil, NEW.name_english),
        NEW.name_english,
        COALESCE(NEW.address, '') || ' ' || COALESCE(NEW.city, '') || ' ' || NEW.district,
        NEW.type || ' ' || COALESCE(NEW.specialty, ''),
        NEW.district || ' ' || NEW.type
    );
END;

-- Trigger: Auto-populate search_index when scam_patterns are inserted
CREATE TRIGGER IF NOT EXISTS fts_scam_patterns_insert AFTER INSERT ON scam_patterns
BEGIN
    INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
    VALUES (
        NEW.id,
        'scam_pattern',
        'security',
        NEW.name_tamil,
        NEW.name_english,
        NEW.description_tamil || ' ' || NEW.red_flags_tamil || ' ' || COALESCE(NEW.prevention_tamil, ''),
        NEW.description_english || ' ' || NEW.red_flags_english || ' ' || COALESCE(NEW.prevention_english, ''),
        NEW.type || ' scam fraud மோசடி'
    );
END;

-- Trigger: Auto-populate search_index when emergency_contacts are inserted
CREATE TRIGGER IF NOT EXISTS fts_emergency_insert AFTER INSERT ON emergency_contacts
BEGIN
    INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
    VALUES (
        NEW.id,
        'emergency_contact',
        'health',
        NEW.name_tamil,
        NEW.name_english,
        NEW.phone || ' ' || COALESCE(NEW.alternate_phone, ''),
        NEW.type,
        'emergency அவசரம் ' || NEW.type || ' ' || COALESCE(NEW.district, '')
    );
END;

-- Trigger: Auto-populate search_index when legal_templates are inserted
CREATE TRIGGER IF NOT EXISTS fts_legal_templates_insert AFTER INSERT ON legal_templates
BEGIN
    INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
    VALUES (
        NEW.id,
        'legal_template',
        'legal',
        NEW.name_tamil,
        NEW.name_english,
        NEW.template_tamil || ' ' || COALESCE(NEW.instructions_tamil, ''),
        COALESCE(NEW.template_english, '') || ' ' || COALESCE(NEW.instructions_english, ''),
        COALESCE(NEW.category, '') || ' legal சட்டம்'
    );
END;

-- Trigger: Auto-populate search_index when scholarships are inserted
CREATE TRIGGER IF NOT EXISTS fts_scholarships_insert AFTER INSERT ON scholarships
BEGIN
    INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
    VALUES (
        NEW.id,
        'scholarship',
        'education',
        NEW.name_tamil,
        NEW.name_english,
        COALESCE(NEW.description_tamil, '') || ' ' || COALESCE(NEW.amount, ''),
        COALESCE(NEW.description_english, ''),
        'scholarship உதவித்தொகை ' || COALESCE(NEW.education_level, '') || ' ' || COALESCE(NEW.category, '')
    );
END;

-- ============================================================================
-- METADATA
-- ============================================================================

-- Database Info: Track schema version and last update
CREATE TABLE IF NOT EXISTS db_info (
    key             TEXT PRIMARY KEY,
    value           TEXT NOT NULL,
    updated_at      TEXT DEFAULT (datetime('now'))
);

-- Insert initial metadata
INSERT OR REPLACE INTO db_info (key, value) VALUES ('schema_version', '1');
INSERT OR REPLACE INTO db_info (key, value) VALUES ('created_at', datetime('now'));

-- ============================================================================
-- AUTO-UPDATE TRIGGERS FOR updated_at COLUMNS
-- ============================================================================

-- Trigger: Auto-update updated_at when categories are modified
CREATE TRIGGER IF NOT EXISTS categories_updated_at AFTER UPDATE ON categories
BEGIN
    UPDATE categories SET updated_at = datetime('now') WHERE id = NEW.id;
END;

-- Trigger: Auto-update updated_at when schemes are modified
CREATE TRIGGER IF NOT EXISTS schemes_updated_at AFTER UPDATE ON schemes
BEGIN
    UPDATE schemes SET updated_at = datetime('now') WHERE id = NEW.id;
END;

-- Trigger: Auto-update updated_at when hospitals are modified
CREATE TRIGGER IF NOT EXISTS hospitals_updated_at AFTER UPDATE ON hospitals
BEGIN
    UPDATE hospitals SET updated_at = datetime('now') WHERE id = NEW.id;
END;

-- Trigger: Auto-update updated_at when scam_patterns are modified
CREATE TRIGGER IF NOT EXISTS scam_patterns_updated_at AFTER UPDATE ON scam_patterns
BEGIN
    UPDATE scam_patterns SET updated_at = datetime('now') WHERE id = NEW.id;
END;

-- Initial data is loaded from separate SQL files in lib/database/data/
-- See: categories.sql, emergency_contacts.sql, thirukkural.sql, schemes.sql, hospitals.sql
