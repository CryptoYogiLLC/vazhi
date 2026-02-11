# VAZHI App Changelog

This log captures all app changes, features, and architectural decisions to help current and future contributors understand the app's evolution.

For model training history, see [`models/TRAINING_LOG.md`](../models/TRAINING_LOG.md).

---

## Version History

| Version | Date | Commit | Summary |
|---------|------|--------|---------|
| v0.1.0 | 2026-02-08 | `3b1e1e2` | Hybrid retrieval architecture (Epic #14) |
| v0.2.0 | 2026-02-10 | `dec3259` | Security hardening (19 code review issues) |
| v0.3.0 | 2026-02-10 | `4c50403` | Remaining high/medium priority features |
| v0.4.0 | 2026-02-11 | `708ca7c` | Full data population, app store prep |
| v0.5.0 | 2026-02-11 | `82a15bc` | Expandable content, bilingual UI, smart routing |
| v0.5.1 | 2026-02-11 | `82a52c0` | Lint cleanup, pre-commit hooks |

---

## Current State (v0.5.1)

- **232 tests** passing (unit, integration, widget, security)
- **0 dart analyze issues** (fatal-infos clean)
- **6 knowledge packs** fully populated in SQLite
- **10 knowledge categories** routed (Thirukkural, schemes, emergency, health, safety, education, legal, siddha medicine, festivals, siddhars)
- **Bilingual UI** (English + Tamil) across all result cards and chat bubbles
- **Pre-commit hooks**: dart format, dart analyze, flutter test, secret detection
- **CI/CD**: GitHub Actions for build, lint, security scan
- **AI model**: Optional download (not yet trained successfully — see training log)

---

## v0.5.1 — Lint Cleanup & Pre-commit Hooks

**Date:** 2026-02-11
**Commit:** `82a52c0`
**Tests:** 232 passing

### Changes

- Fixed 27 dart analyze warnings across 6 files:
  - `generic_data_service.dart`: 9 `curly_braces_in_flow_control_structures`
  - `chat_screen.dart`: `prefer_final_fields`, `unnecessary_underscores`
  - `voice_service.dart`: 3 `deprecated_member_use` — migrated from individual `listenMode`/`cancelOnError`/`partialResults` params to `SpeechListenOptions`
  - `emergency_service.dart`, `healthcare_service.dart`, `scheme_service.dart`, `thirukkural_service.dart`: `unnecessary_string_interpolations`
- Applied `dart format` to all 48 Dart files for consistent style
- Added `flutter-test` pre-commit hook to catch test failures before push

### Reason for Change

Pre-commit hooks were added to match the CI pipeline locally. Running `pre-commit run --all-files` exposed 27 lint warnings and formatting inconsistencies that had accumulated. Fixing everything ensures a clean baseline for release — "we can't have an app with issues be released."

---

## v0.5.0 — Expandable Content, Bilingual UI, Smart Routing

**Date:** 2026-02-11
**Commit:** `82a15bc`
**Tests:** 232 passing (up from 228)

### Features

1. **Expandable content in KnowledgeResultCard**
   - Long results now collapse at 180px with a gradient fade
   - Bilingual "Show more / மேலும் காட்டு" and "Show less / குறைவாக காட்டு" toggle
   - Uses `Offstage` widget for hidden content measurement (avoids layout impact)
   - Converted `KnowledgeResultCard` from `ConsumerWidget` to `ConsumerStatefulWidget` for local expand/collapse state

2. **6 new knowledge categories in query router**
   - Education (`_isEducationQuery`): scholarships, exams, NEET, TNPSC, etc.
   - Legal (`_isLegalQuery`): RTI, consumer rights, tenant, FIR, etc.
   - Safety (existing, expanded): scam, OTP, cyber safety keywords
   - Siddha Medicine (`_isSiddhaMedicineQuery`): siddha, herbal, naturopathy
   - Festivals (`_isFestivalQuery`): Pongal, Diwali, Tamil New Year, etc.
   - Siddhars (`_isSiddharQuery`): Agathiyar, Thirumoolar, Bogar, etc.

3. **GenericDataService** — new service handling all direct-DB lookup categories (scams, scholarships, exams, legal rights, legal templates, siddha medicine, festivals, siddhars, cyber safety)

4. **Bilingual UI** across `KnowledgeResultCard` and `HybridMessageBubble`
   - Category names shown in both English and Tamil
   - All labels and buttons bilingual using `t(en, ta)` helper with `languageProvider`

5. **Smart hybrid routing** — conversational queries containing category keywords (e.g., "how to file RTI?", "why is scholarship important?") now route as `hybrid` instead of `deterministic`, so the user gets both the factual data AND an AI explanation instead of being force-fed raw DB results

6. **Category icon assets**: `vazhi-emergency.png`, `vazhi-health.png`, `vazhi-home.png`, `vazhi-kural.png`

### Reason for Change

User feedback: (a) long content was getting truncated with no way to see the full text, (b) query router was force-feeding deterministic content when the user asked a proper question that happened to contain a keyword like "RTI" or "scam" — the fix ensures conversational patterns are detected and routed through the hybrid path.

### Key Design Decision

The `_needsExplanation()` check (which detects patterns like "how", "why", "explain", "what is", etc.) was already used by Thirukkural and Scheme handlers but was missing from all 6 newer category handlers. This was a systematic gap — all category handlers now use it consistently.

---

## v0.4.0 — Full Data Population & App Store Prep

**Date:** 2026-02-11
**Commits:** `708ca7c`, `68ab08b`, `7e06cc0`
**Tests:** 228 passing

### Features

1. **11 bilingual SQL data files** (~390 records) covering all 6 content packs:
   - Culture: siddhars (18), festivals (15)
   - Security: scam patterns (25), cyber safety tips (15)
   - Education: scholarships (20), competitive exams (15)
   - Legal: legal rights (20), legal templates (15)
   - Healthcare: siddha medicine (20)
   - Government: additional schemes

2. **KnowledgeDatabase expanded** with query methods, FTS5 indexing, and data loading for all new tables

3. **Release signing** for Android (`build.gradle.kts`) — loads keystore credentials from `key.properties` (gitignored), falls back to debug signing if absent

4. **GitHub Pages deployment**
   - Landing page and privacy policy (HTML + markdown)
   - `.nojekyll` file for proper static serving
   - GitHub Actions workflow for Pages deployment

5. **Android/iOS platform config**
   - `INTERNET` permission in Android manifest
   - iOS privacy descriptions for microphone and speech recognition

### Reason for Change

Preparing the app for initial app store submission as a "lite" version (SQLite-only, no AI model). All 6 knowledge packs needed to be populated with real data rather than placeholders.

### Issue Found & Fixed

Column name mismatches in `schemes.sql` caused silent INSERT failures — all INSERTs succeeded syntactically but wrote NULLs for mismatched columns. Root cause: SQL column names didn't match the Dart model's expected keys. Fixed by aligning column names across SQL and Dart.

---

## v0.3.0 — Remaining High & Medium Priority Features

**Date:** 2026-02-10
**Commit:** `4c50403`
**Tests:** 228 passing (up from 85)

### Features

1. **Encrypted storage** (#27) — Hive boxes encrypted with `flutter_secure_storage` for sensitive local data
2. **Training data rebalancer** (#29) — Script to fix Thirukkural skew in training data
3. **Preflight training validation** (#33) — Pre-training checks to catch format/quality issues early
4. **Accessibility semantics** (#34) — Semantic labels on chat input and feedback buttons
5. **Database migration framework** (#35) — Versioned schema changes with `migrations.dart`
6. **Input validation** (#36) — Length limits and sanitization for user queries (ReDoS-safe patterns)
7. **JSON schema validation** (#37) — Schema validation for training data format
8. **i18n infrastructure** (#38) — English (`app_en.arb`) and Tamil (`app_ta.arb`) ARB files
9. **Inference metrics** (#39) — First token latency, tokens/sec tracking
10. **Streaming token response** (#40) — Support for streaming AI responses with metrics display

### Reason for Change

Code review identified 19 issues (#22-#40). After the critical/high security fixes in v0.2.0, this release addressed the remaining high and medium priority items to bring the app to production readiness.

---

## v0.2.0 — Security Hardening

**Date:** 2026-02-10
**Commits:** `dec3259`, `1953fc9`, `38258dd`, `125338c`, `dbaa3c2`, `39ec8f6`
**Tests:** 228 passing (up from 85)

### Security Fixes (from Multi-Agent Code Review)

A 4-expert code review (Security, Mobile/Flutter, AI/ML, Data Pipeline) identified 19 issues. All were resolved:

**Critical:**
- FTS5 search index populated with triggers and bulk population (was completely non-functional)
- SSL certificate pinning with allowed hosts whitelist (MITM prevention)
- Redirect URL validation to prevent MITM attacks
- Production logging replaced with conditional debug logging

**High:**
- SHA256 model hash verification for download integrity
- Memory leaks fixed in `VoiceService` with proper `dispose()` methods
- `autoDispose` added to voice `StateNotifier` providers
- `created_at`/`updated_at` timestamps added to database tables
- Data merge scripts made idempotent with ID deduplication

### Test Suite (#30)

Added 8 new test files (143 new tests):
- Models: Message, Thirukkural, UserFeedback
- Providers: Chat, Voice (mocked)
- Services: ModelDownloadService
- Database: KnowledgeDatabase SQL validation
- Security: URL validation for MITM prevention

### Code Quality

- Replaced `.withOpacity(x)` with `.withValues(alpha: x)` (38 occurrences — Flutter deprecation)
- Added `library;` directive to files with doc comments (41 files — Dart 3 requirement)
- Pre-commit hooks: gitleaks, dart format/analyze, Python black/flake8/bandit, large file blocking
- GitHub Actions CI/CD: Flutter build/format/analyze, Python linting, security scanning

### Reason for Change

The code review consensus report rated Security at C- and Mobile at B. These fixes brought security to production-grade: encrypted storage, cert pinning, input validation, verified downloads. The test suite went from 85 to 228 tests for confidence in the hybrid retrieval paths.

---

## v0.1.0 — Hybrid Retrieval Architecture

**Date:** 2026-02-08
**Commit:** `3b1e1e2`
**Tests:** 85 passing

### Architecture

Major pivot: instead of blocking on AI model training (9 failed attempts), implemented a **hybrid retrieval architecture** that provides immediate value through deterministic SQLite lookups, with optional AI enhancement.

```
User Query → Query Router → [deterministic | hybrid | aiRequired]
                               ↓               ↓           ↓
                          SQLite lookup    SQLite + AI    AI only
```

### Components

**Data Layer:**
- `thirukkural.sql`: 1,330 verses with Tamil meanings
- `schemes.sql`: 14 government schemes (TN + Central)
- `hospitals.sql`: 25 healthcare facilities
- `categories.sql`: 7 knowledge categories, 45 query patterns

**Query Router (`query_router.dart`):**
- `QueryType` enum: `deterministic`, `hybrid`, `aiRequired`
- `KnowledgeCategory` enum with Tamil names
- Pattern matching for Tamil and English queries
- `_needsExplanation()` detects conversational patterns (how, why, explain, etc.)

**Retrieval Services:**
- `KnowledgeService` — unified facade for all retrievals
- `ThirukkuralService` — verse lookup by number, athikaram, search, random
- `SchemeService` — government scheme info, eligibility, documents
- `EmergencyService` — emergency contacts by type, district, national numbers
- `HealthcareService` — hospitals by district, type, CMCHIS, emergency

**UI Layer:**
- `KnowledgeResultCard` — rich display for deterministic results
- `HybridMessageBubble` — handles all message types (deterministic, hybrid, AI)
- `ModelStatusIndicator` — download status badge
- `DownloadDialog` — pause/resume, progress, speed, ETA, cellular warning

**Providers:**
- `HybridChatProvider` — integrates knowledge retrieval + AI responses
- Query router provider with Riverpod

### Reason for Change

After 7 failed training attempts (v0.1-v0.7), the app had no way to provide value. The hybrid architecture decouples the app from the AI model: users get immediate, accurate answers for factual queries (Thirukkural verses, emergency numbers, scheme eligibility) from SQLite, while conversational questions wait for the optional AI model. This was documented in ADR-009.

### Key Design Decision

The `RetrievalResult<T>` generic class provides a unified response type across all services with states: `found`, `list`, `notFound`, `error`. Each result carries `category`, `displayTitle`, `formattedResponse`, enabling the UI to render any knowledge type consistently.

---

## Pre-App: Flutter Initialization

**Date:** 2026-02-05 to 2026-02-07
**Commits:** `36ec5b2` through `db03cca`

### What Happened

- Initial project structure with Flutter 3.24 + Riverpod 2.6
- Chat UI with Tamil support, category selection, settings drawer
- Voice I/O: Tamil STT (speech_to_text) and TTS
- Basic model download service (for the planned GGUF model)
- Architecture documentation, ADRs, sprint planning
- 6 domain data packs created (3,007 bilingual training pairs)
- Thirukkural nullable `iyal` fix and Tamil ordinal number support

This phase focused primarily on training data creation and model training experiments (see `models/TRAINING_LOG.md`). The Flutter app was scaffolded but had minimal functionality beyond the chat UI skeleton.

---

## Architecture Overview

### Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.24 |
| State Management | Riverpod 2.6 |
| Local Database | SQLite (sqflite) with FTS5 |
| Encrypted Storage | Hive + flutter_secure_storage |
| Voice Input | speech_to_text (Tamil STT) |
| Voice Output | flutter_tts (Tamil TTS) |
| AI Model | Qwen3-0.6B GGUF (optional, not yet trained) |

### File Structure (Key Files)

```
vazhi_app/lib/
├── database/
│   ├── knowledge_database.dart     # SQLite facade (all tables, FTS5, queries)
│   └── migrations/migrations.dart  # Versioned schema changes
├── models/
│   ├── query_result.dart           # RetrievalResult<T> generic result type
│   ├── thirukkural.dart            # Thirukkural + Athikaram models
│   ├── scheme.dart                 # Scheme + Eligibility + Document models
│   ├── hospital.dart               # Hospital model
│   └── emergency_contact.dart      # EmergencyContact model
├── providers/
│   ├── hybrid_chat_provider.dart   # Main chat state (knowledge + AI)
│   └── knowledge_provider.dart     # Knowledge retrieval state
├── services/
│   ├── query_router.dart           # Query classification (10 categories)
│   ├── voice_service.dart          # Tamil STT/TTS
│   └── retrieval/
│       ├── knowledge_service.dart  # Unified retrieval facade
│       ├── thirukkural_service.dart
│       ├── scheme_service.dart
│       ├── healthcare_service.dart
│       ├── emergency_service.dart
│       └── generic_data_service.dart  # 8 categories (scams, scholarships, etc.)
├── screens/
│   └── chat_screen.dart            # Main chat screen
└── widgets/
    ├── knowledge_result_card.dart  # Expandable result display (bilingual)
    ├── hybrid_message_bubble.dart  # All message types (bilingual)
    ├── download_dialog.dart        # Model download UI
    └── ...
```

### Query Routing Categories

| Category | Route Type | Service | Keywords |
|----------|-----------|---------|----------|
| Thirukkural | deterministic/hybrid | ThirukkuralService | குறள், kural, athikaram, verse numbers |
| Schemes | deterministic/hybrid | SchemeService | திட்டம், scheme, pension, ration |
| Emergency | deterministic | EmergencyService | அவசரம், emergency, 108, police |
| Health | deterministic/hybrid | HealthcareService | மருத்துவமனை, hospital, doctor |
| Safety | deterministic/hybrid | GenericDataService | மோசடி, scam, OTP, phishing |
| Education | deterministic/hybrid | GenericDataService | scholarship, NEET, TNPSC, exam |
| Legal | deterministic/hybrid | GenericDataService | RTI, consumer, tenant, FIR |
| Siddha Medicine | deterministic/hybrid | GenericDataService | சித்த, siddha, herbal |
| Festivals | deterministic/hybrid | GenericDataService | பொங்கல், Diwali, festival |
| Siddhars | deterministic/hybrid | GenericDataService | அகத்தியர், Thirumoolar, siddhar |

**Routing logic:** Plain keywords → `deterministic` (show DB results). Conversational patterns ("how to...", "why is...", "explain...") with keywords → `hybrid` (show DB results + AI explanation). No keyword match → `aiRequired` (pure AI response).

---

## Lessons Learned (App-Specific)

1. **Ship without AI** — The hybrid architecture lets users get value immediately. Don't block the entire app on model training.
2. **FTS5 needs explicit population** — Creating the virtual table is not enough; you need INSERT triggers or bulk population. This was a completely non-functional feature that passed code review.
3. **Column name mismatches cause silent failures** — SQL INSERTs succeed but write NULLs. Always verify data after population.
4. **`_needsExplanation()` must be applied consistently** — When adding new category handlers, always include the conversational pattern check. Missing it causes force-feeding of deterministic results for questions that need explanation.
5. **Pre-commit hooks save CI time** — Adding dart format, analyze, and flutter test locally catches issues before they fail in GitHub Actions.
6. **`Offstage` not `Opacity(0)`** — For hidden layout measurement, `Offstage` reports zero size. `Opacity(0)` still takes up layout space and breaks the design.
7. **`ConsumerWidget` → `ConsumerStatefulWidget`** — When adding local mutable state (like expand/collapse), you must convert and prefix all field refs with `widget.`.
8. **Deprecated API migration matters** — SpeechToText's `listenMode`/`cancelOnError`/`partialResults` → `SpeechListenOptions`. Flutter's `.withOpacity()` → `.withValues(alpha:)`. Staying on deprecated APIs creates lint noise and eventual breakage.
9. **Security is non-negotiable for offline apps** — Even fully local apps need: encrypted storage (not just Hive), input validation (ReDoS-safe), URL allowlists for any downloads, SHA256 verification.
10. **Bilingual UI needs a pattern** — The `t(en, ta)` helper with `languageProvider` works well for inline translation without heavy i18n infrastructure.
