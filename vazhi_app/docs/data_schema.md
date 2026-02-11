# VAZHI Knowledge Pack Data Schema

This document defines the SQLite database schema for deterministic data retrieval in the hybrid architecture.

## Database Overview

- **Database**: `vazhi_knowledge.db`
- **Storage**: Bundled with app in `assets/data/`
- **Size**: ~1.5-2 MB compressed
- **Engine**: SQLite with FTS5 for Tamil full-text search

---

## Schema Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CULTURE PACK                                   │
├─────────────────┬─────────────────┬─────────────────┬───────────────────┤
│   thirukkural   │    siddhars     │    festivals    │     temples       │
└────────┬────────┴────────┬────────┴────────┬────────┴─────────┬─────────┘
         │                 │                 │                  │
         └─────────────────┴─────────────────┴──────────────────┘
                                    │
                              categories
                                    │
┌─────────────────────────────────────────────────────────────────────────┐
│                          GOVERNMENT PACK                                 │
├─────────────────┬─────────────────┬─────────────────┬───────────────────┤
│     schemes     │    documents    │    offices      │   eligibility     │
└─────────────────┴─────────────────┴─────────────────┴───────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          EDUCATION PACK                                  │
├─────────────────┬─────────────────┬─────────────────┬───────────────────┤
│  scholarships   │     exams       │  institutions   │    courses        │
└─────────────────┴─────────────────┴─────────────────┴───────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                            LEGAL PACK                                    │
├─────────────────┬─────────────────┬─────────────────┬───────────────────┤
│    templates    │     rights      │   procedures    │    contacts       │
└─────────────────┴─────────────────┴─────────────────┴───────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          HEALTHCARE PACK                                 │
├─────────────────┬─────────────────┬─────────────────┬───────────────────┤
│    hospitals    │  siddha_medicine│   emergency     │   health_tips     │
└─────────────────┴─────────────────┴─────────────────┴───────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          SECURITY PACK                                   │
├─────────────────┬─────────────────┬─────────────────┬───────────────────┤
│  scam_patterns  │  cyber_safety   │   reporting     │   emergency       │
└─────────────────┴─────────────────┴─────────────────┴───────────────────┘
```

---

## Common Tables

### categories
Master table for organizing all content by knowledge pack.

```sql
CREATE TABLE categories (
    id              TEXT PRIMARY KEY,      -- 'culture', 'govt', 'education', etc.
    name_tamil      TEXT NOT NULL,         -- 'கலாச்சாரம்'
    name_english    TEXT NOT NULL,         -- 'Culture'
    description     TEXT,
    icon            TEXT,                  -- Emoji or icon name
    color           TEXT,                  -- Hex color code
    sort_order      INTEGER DEFAULT 0
);
```

### search_index (FTS5)
Full-text search across all content in Tamil and English.

```sql
CREATE VIRTUAL TABLE search_index USING fts5(
    content_id,         -- Reference to source table
    content_type,       -- 'thirukkural', 'scheme', 'hospital', etc.
    category_id,        -- FK to categories
    title_tamil,
    title_english,
    content_tamil,
    content_english,
    keywords,           -- Additional searchable keywords
    tokenize='unicode61'
);
```

---

## Culture Pack Tables

### thirukkural
All 1,330 Thirukkural verses with metadata.

```sql
CREATE TABLE thirukkural (
    kural_number    INTEGER PRIMARY KEY,   -- 1-1330
    verse_line1     TEXT NOT NULL,         -- First line of kural
    verse_line2     TEXT NOT NULL,         -- Second line of kural
    verse_full      TEXT NOT NULL,         -- Combined verse

    -- Classification
    paal            TEXT NOT NULL,         -- அறத்துப்பால், பொருட்பால், காமத்துப்பால்
    paal_english    TEXT NOT NULL,         -- Virtue, Wealth, Love
    iyal            TEXT NOT NULL,         -- இயல் (section)
    athikaram       TEXT NOT NULL,         -- அதிகாரம் (chapter) Tamil
    athikaram_english TEXT NOT NULL,       -- Chapter English
    athikaram_number INTEGER NOT NULL,     -- 1-133

    -- Meanings (deterministic - from authoritative sources)
    meaning_tamil   TEXT,                  -- Tamil prose meaning
    meaning_english TEXT,                  -- English translation

    -- Metadata
    keywords_tamil  TEXT,                  -- Comma-separated keywords
    keywords_english TEXT
);

-- Index for fast chapter lookup
CREATE INDEX idx_kural_athikaram ON thirukkural(athikaram_number);
CREATE INDEX idx_kural_paal ON thirukkural(paal);
```

### siddhars
Information about the 18 Siddhars and their contributions.

```sql
CREATE TABLE siddhars (
    id              INTEGER PRIMARY KEY,
    name_tamil      TEXT NOT NULL,         -- 'திருமூலர்'
    name_english    TEXT NOT NULL,         -- 'Thirumoolar'

    -- Biography
    period          TEXT,                  -- Historical period
    birthplace      TEXT,

    -- Contributions
    famous_work     TEXT,                  -- 'திருமந்திரம்'
    work_english    TEXT,                  -- 'Thirumandhiram'
    expertise       TEXT,                  -- 'Yoga, Medicine'

    -- Content
    brief_tamil     TEXT NOT NULL,         -- Short bio in Tamil
    brief_english   TEXT NOT NULL,
    teachings       TEXT,                  -- Key teachings

    -- Media
    image_asset     TEXT                   -- Path to image if available
);
```

### festivals
Tamil and Hindu festivals with dates and significance.

```sql
CREATE TABLE festivals (
    id              INTEGER PRIMARY KEY,
    name_tamil      TEXT NOT NULL,         -- 'பொங்கல்'
    name_english    TEXT NOT NULL,         -- 'Pongal'

    -- Timing
    tamil_month     TEXT,                  -- 'தை'
    english_month   TEXT,                  -- 'January'
    duration_days   INTEGER DEFAULT 1,

    -- Details
    significance_tamil TEXT NOT NULL,
    significance_english TEXT NOT NULL,
    rituals_tamil   TEXT,
    rituals_english TEXT,

    -- Categorization
    type            TEXT,                  -- 'harvest', 'religious', 'cultural'
    region          TEXT DEFAULT 'Tamil Nadu'
);
```

---

## Government Pack Tables

### schemes
Government welfare schemes with eligibility and process.

```sql
CREATE TABLE schemes (
    id              TEXT PRIMARY KEY,      -- 'pmkisan', 'cmchis'
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,

    -- Categorization
    level           TEXT NOT NULL,         -- 'central', 'state', 'district'
    department      TEXT,

    -- Details
    description_tamil TEXT NOT NULL,
    description_english TEXT NOT NULL,

    -- Benefits
    benefit_type    TEXT,                  -- 'cash', 'subsidy', 'service'
    benefit_amount  TEXT,                  -- '₹6000/year' or description

    -- Process
    how_to_apply_tamil TEXT,
    how_to_apply_english TEXT,
    application_url TEXT,

    -- Status
    is_active       INTEGER DEFAULT 1,
    last_updated    TEXT                   -- ISO date
);

CREATE INDEX idx_schemes_level ON schemes(level);
```

### scheme_eligibility
Eligibility criteria for schemes (normalized).

```sql
CREATE TABLE scheme_eligibility (
    id              INTEGER PRIMARY KEY,
    scheme_id       TEXT NOT NULL,

    -- Criteria
    criteria_type   TEXT NOT NULL,         -- 'age', 'income', 'category', 'occupation'
    criteria_tamil  TEXT NOT NULL,
    criteria_english TEXT NOT NULL,

    -- Validation
    min_value       TEXT,                  -- For numeric ranges
    max_value       TEXT,
    allowed_values  TEXT,                  -- JSON array for enums

    FOREIGN KEY (scheme_id) REFERENCES schemes(id)
);

CREATE INDEX idx_eligibility_scheme ON scheme_eligibility(scheme_id);
```

### scheme_documents
Required documents for scheme applications.

```sql
CREATE TABLE scheme_documents (
    id              INTEGER PRIMARY KEY,
    scheme_id       TEXT NOT NULL,

    document_tamil  TEXT NOT NULL,         -- 'ஆதார் அட்டை'
    document_english TEXT NOT NULL,        -- 'Aadhaar Card'
    is_mandatory    INTEGER DEFAULT 1,
    notes           TEXT,

    FOREIGN KEY (scheme_id) REFERENCES schemes(id)
);
```

### govt_offices
Government office contacts and addresses.

```sql
CREATE TABLE govt_offices (
    id              INTEGER PRIMARY KEY,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,

    -- Location
    district        TEXT,
    address         TEXT,
    pincode         TEXT,

    -- Contact
    phone           TEXT,
    email           TEXT,
    website         TEXT,

    -- Timing
    working_hours   TEXT,
    holidays        TEXT,

    -- Categorization
    office_type     TEXT,                  -- 'taluk', 'district', 'state'
    department      TEXT
);

CREATE INDEX idx_offices_district ON govt_offices(district);
```

---

## Education Pack Tables

### scholarships
Available scholarships for students.

```sql
CREATE TABLE scholarships (
    id              TEXT PRIMARY KEY,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,

    -- Provider
    provider        TEXT,                  -- 'TN Govt', 'Central Govt', 'Private'
    department      TEXT,

    -- Details
    description_tamil TEXT,
    description_english TEXT,
    amount          TEXT,                  -- '₹10000/year'

    -- Eligibility
    education_level TEXT,                  -- 'school', 'ug', 'pg', 'research'
    category        TEXT,                  -- 'sc', 'st', 'obc', 'general', 'all'
    income_limit    TEXT,

    -- Application
    application_start TEXT,                -- Month or date
    application_end TEXT,
    apply_url       TEXT,

    is_active       INTEGER DEFAULT 1
);
```

### institutions
Educational institutions directory.

```sql
CREATE TABLE institutions (
    id              INTEGER PRIMARY KEY,
    name_tamil      TEXT,
    name_english    TEXT NOT NULL,

    -- Type
    type            TEXT NOT NULL,         -- 'school', 'college', 'university', 'iit', 'iti'
    board           TEXT,                  -- 'state', 'cbse', 'icse'

    -- Location
    district        TEXT,
    city            TEXT,
    address         TEXT,
    pincode         TEXT,

    -- Contact
    phone           TEXT,
    email           TEXT,
    website         TEXT,

    -- Details
    courses         TEXT,                  -- JSON array of courses
    accreditation   TEXT,
    established     INTEGER
);

CREATE INDEX idx_inst_district ON institutions(district);
CREATE INDEX idx_inst_type ON institutions(type);
```

### exams
Competitive and entrance exams.

```sql
CREATE TABLE exams (
    id              TEXT PRIMARY KEY,      -- 'neet', 'jee', 'tnpsc'
    name_tamil      TEXT,
    name_english    TEXT NOT NULL,

    -- Details
    conducting_body TEXT,
    level           TEXT,                  -- 'national', 'state'

    -- Eligibility
    eligibility_tamil TEXT,
    eligibility_english TEXT,

    -- Important info
    exam_pattern    TEXT,
    syllabus_url    TEXT,
    official_site   TEXT,

    -- Dates (updated annually)
    application_start TEXT,
    application_end TEXT,
    exam_date       TEXT,
    result_date     TEXT
);
```

---

## Legal Pack Tables

### legal_templates
Templates for legal documents and applications.

```sql
CREATE TABLE legal_templates (
    id              TEXT PRIMARY KEY,      -- 'rti_application', 'fir_format'
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,

    -- Categorization
    category        TEXT,                  -- 'rti', 'consumer', 'property', 'police'

    -- Template
    template_tamil  TEXT NOT NULL,         -- Template with placeholders
    template_english TEXT,

    -- Instructions
    instructions_tamil TEXT,
    instructions_english TEXT,

    -- Submission
    submit_to       TEXT,
    submit_address  TEXT,
    fees            TEXT
);
```

### legal_rights
Citizen rights information.

```sql
CREATE TABLE legal_rights (
    id              INTEGER PRIMARY KEY,
    title_tamil     TEXT NOT NULL,
    title_english   TEXT NOT NULL,

    -- Content
    description_tamil TEXT NOT NULL,
    description_english TEXT NOT NULL,

    -- Legal reference
    act_name        TEXT,                  -- 'Consumer Protection Act 2019'
    section         TEXT,

    -- Categorization
    category        TEXT,                  -- 'consumer', 'tenant', 'employee', 'citizen'

    -- What to do
    how_to_claim_tamil TEXT,
    how_to_claim_english TEXT
);
```

---

## Healthcare Pack Tables

### hospitals
Hospital and health facility directory.

```sql
CREATE TABLE hospitals (
    id              INTEGER PRIMARY KEY,
    name_tamil      TEXT,
    name_english    TEXT NOT NULL,

    -- Type
    type            TEXT NOT NULL,         -- 'govt', 'private', 'phc', 'ghq'
    specialty       TEXT,                  -- 'general', 'maternity', 'trauma', etc.

    -- Location
    district        TEXT NOT NULL,
    city            TEXT,
    address         TEXT,
    pincode         TEXT,
    latitude        REAL,
    longitude       REAL,

    -- Contact
    phone           TEXT,
    emergency_phone TEXT,
    email           TEXT,

    -- Facilities
    beds            INTEGER,
    has_emergency   INTEGER DEFAULT 0,
    has_ambulance   INTEGER DEFAULT 0,

    -- Insurance
    accepts_cmchis  INTEGER DEFAULT 0,
    accepts_ayushman INTEGER DEFAULT 0
);

CREATE INDEX idx_hosp_district ON hospitals(district);
CREATE INDEX idx_hosp_type ON hospitals(type);
```

### siddha_medicine
Siddha remedies and practices.

```sql
CREATE TABLE siddha_medicine (
    id              INTEGER PRIMARY KEY,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT,

    -- Categorization
    category        TEXT,                  -- 'herb', 'mineral', 'practice'

    -- Details
    description_tamil TEXT NOT NULL,
    description_english TEXT,

    -- Usage (general info only - not medical advice)
    traditional_use TEXT,
    preparation     TEXT,

    -- Caution
    disclaimer      TEXT DEFAULT 'இது பொதுவான தகவல் மட்டுமே. மருத்துவரை அணுகவும்.'
);
```

### emergency_contacts
Emergency service contacts.

```sql
CREATE TABLE emergency_contacts (
    id              INTEGER PRIMARY KEY,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,

    -- Contact
    phone           TEXT NOT NULL,
    alternate_phone TEXT,

    -- Categorization
    type            TEXT NOT NULL,         -- 'police', 'fire', 'medical', 'disaster', 'women'

    -- Scope
    district        TEXT,                  -- NULL means statewide/national
    is_national     INTEGER DEFAULT 0
);

CREATE INDEX idx_emergency_type ON emergency_contacts(type);
```

---

## Security Pack Tables

### scam_patterns
Known scam patterns for detection.

```sql
CREATE TABLE scam_patterns (
    id              INTEGER PRIMARY KEY,
    name_tamil      TEXT NOT NULL,
    name_english    TEXT NOT NULL,

    -- Pattern
    type            TEXT NOT NULL,         -- 'otp', 'lottery', 'job', 'loan', 'kyc'

    -- Description
    description_tamil TEXT NOT NULL,
    description_english TEXT NOT NULL,

    -- Detection
    red_flags_tamil TEXT NOT NULL,         -- What to look for
    red_flags_english TEXT NOT NULL,
    example_messages TEXT,                 -- JSON array of example scam messages

    -- Prevention
    prevention_tamil TEXT,
    prevention_english TEXT,

    -- Reporting
    report_to       TEXT,
    report_number   TEXT
);

CREATE INDEX idx_scam_type ON scam_patterns(type);
```

### cyber_safety_tips
Cyber safety guidelines.

```sql
CREATE TABLE cyber_safety_tips (
    id              INTEGER PRIMARY KEY,
    title_tamil     TEXT NOT NULL,
    title_english   TEXT NOT NULL,

    -- Content
    tip_tamil       TEXT NOT NULL,
    tip_english     TEXT NOT NULL,

    -- Categorization
    category        TEXT,                  -- 'password', 'banking', 'social', 'phone'
    priority        INTEGER DEFAULT 0      -- Higher = more important
);
```

---

## Query Router Support Table

### query_patterns
Patterns for routing queries to deterministic vs AI path.

```sql
CREATE TABLE query_patterns (
    id              INTEGER PRIMARY KEY,
    pattern         TEXT NOT NULL,         -- Regex pattern
    pattern_type    TEXT NOT NULL,         -- 'keyword', 'regex', 'prefix'

    -- Routing
    route_to        TEXT NOT NULL,         -- 'deterministic', 'ai', 'hybrid'
    target_table    TEXT,                  -- Which table to query

    -- Examples
    example_queries TEXT,                  -- JSON array of example queries

    priority        INTEGER DEFAULT 0      -- Higher = checked first
);

CREATE INDEX idx_pattern_priority ON query_patterns(priority DESC);
```

---

## Sample Data

### Thirukkural Sample

```sql
INSERT INTO thirukkural VALUES (
    1,
    'அகர முதல எழுத்தெல்லாம்',
    'ஆதி பகவன் முதற்றே உலகு',
    'அகர முதல எழுத்தெல்லாம் ஆதி பகவன் முதற்றே உலகு',
    'அறத்துப்பால்',
    'Virtue',
    'பாயிரவியல்',
    'கடவுள் வாழ்த்து',
    'The Praise of God',
    1,
    'எழுத்துக்கள் எல்லாம் அகரத்தை முதலாகக் கொண்டிருக்கின்றன. அதுபோல உலகம் கடவுளை முதலாகக் கொண்டிருக்கிறது.',
    'As the letter A is the first of all letters, so the eternal God is first in the world.',
    'அகரம்,எழுத்து,கடவுள்,உலகம்',
    'alphabet,god,world,first'
);
```

### Scheme Sample

```sql
INSERT INTO schemes VALUES (
    'pmkisan',
    'பிரதம மந்திரி கிசான் சம்மான் நிதி',
    'PM Kisan Samman Nidhi',
    'central',
    'Ministry of Agriculture',
    'விவசாயிகளுக்கு ஆண்டுக்கு ₹6000 நேரடி பண உதவி',
    'Direct cash transfer of ₹6000 per year to farmers',
    'cash',
    '₹6000/year (₹2000 x 3 installments)',
    'pmkisan.gov.in போர்டலில் பதிவு செய்யுங்கள்',
    'Register at pmkisan.gov.in portal',
    'https://pmkisan.gov.in',
    1,
    '2026-01-01'
);

INSERT INTO scheme_eligibility VALUES
    (1, 'pmkisan', 'occupation', 'விவசாயி', 'Farmer', NULL, NULL, NULL),
    (2, 'pmkisan', 'land', '2 ஹெக்டேர் வரை நிலம்', 'Up to 2 hectares of land', '0', '2', NULL);

INSERT INTO scheme_documents VALUES
    (1, 'pmkisan', 'ஆதார் அட்டை', 'Aadhaar Card', 1, NULL),
    (2, 'pmkisan', 'நில ஆவணங்கள்', 'Land Documents', 1, NULL),
    (3, 'pmkisan', 'வங்கி பாஸ்புக்', 'Bank Passbook', 1, NULL);
```

---

## Migration Strategy

1. **Initial data load**: Bundle `vazhi_knowledge.db` in `assets/data/`
2. **App startup**: Copy to app documents directory if not exists
3. **Updates**: Check version, download delta updates via API
4. **Offline**: Always use local copy

```dart
class KnowledgeDatabase {
  static const String dbName = 'vazhi_knowledge.db';
  static const int dbVersion = 1;

  static Future<Database> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    // Copy from assets if not exists
    if (!await File(path).exists()) {
      final data = await rootBundle.load('assets/data/$dbName');
      await File(path).writeAsBytes(data.buffer.asUint8List());
    }

    return openDatabase(path, version: dbVersion);
  }
}
```

---

## Size Estimates

| Table | Records | Size |
|-------|---------|------|
| thirukkural | 1,330 | ~400 KB |
| siddhars | 18 | ~20 KB |
| festivals | 50 | ~30 KB |
| schemes | 100 | ~150 KB |
| scheme_eligibility | 300 | ~50 KB |
| scheme_documents | 200 | ~30 KB |
| govt_offices | 200 | ~100 KB |
| scholarships | 50 | ~80 KB |
| institutions | 200 | ~150 KB |
| exams | 30 | ~50 KB |
| legal_templates | 20 | ~100 KB |
| legal_rights | 50 | ~80 KB |
| hospitals | 500 | ~200 KB |
| siddha_medicine | 100 | ~60 KB |
| emergency_contacts | 50 | ~20 KB |
| scam_patterns | 50 | ~80 KB |
| cyber_safety_tips | 30 | ~30 KB |
| search_index (FTS5) | - | ~200 KB |
| **Total** | ~3,300 | **~1.8 MB** |

Compressed (gzip): **~600 KB**
