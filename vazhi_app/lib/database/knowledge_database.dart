/// Knowledge Database
///
/// SQLite database manager for deterministic data retrieval.
/// Handles initialization, migrations, and provides access to knowledge data.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class KnowledgeDatabase {
  static const String _dbName = 'vazhi_knowledge.db';
  static const int _dbVersion = 1;
  static const int _maxQueryLength = 500;
  static const int _maxSearchResults = 50;

  static Database? _database;
  static bool _isInitialized = false;

  /// Sanitize and validate user input to prevent SQL injection and DoS
  static String _sanitizeQuery(String query, {int? maxLength}) {
    final limit = maxLength ?? _maxQueryLength;
    // Truncate if too long
    if (query.length > limit) {
      query = query.substring(0, limit);
    }
    // Remove null bytes and other control characters
    query = query.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    return query.trim();
  }

  /// Validate integer input within range
  static int? _validateIntRange(int value, int min, int max) {
    if (value < min || value > max) {
      return null;
    }
    return value;
  }

  /// Debug logging helper - only logs in debug mode
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('KnowledgeDatabase: $message');
    }
  }

  /// Get the database instance (singleton)
  static Future<Database> get database async {
    if (_database != null && _isInitialized) {
      return _database!;
    }
    _database = await _initDatabase();
    _isInitialized = true;
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    _log('_initDatabase called');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    _log('DB exists check at path');

    // Check if database exists
    final exists = await databaseExists(path);
    _log('DB exists: $exists');

    if (!exists) {
      // Create directory if needed
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Create empty database and run migrations
      final db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      return db;
    }

    // Open existing database
    return openDatabase(path, version: _dbVersion, onUpgrade: _onUpgrade);
  }

  /// Create database tables (called on first creation)
  static Future<void> _onCreate(Database db, int version) async {
    _log('_onCreate called with version $version');

    // Load and execute the initial schema SQL
    String schema;
    try {
      schema = await rootBundle.loadString(
        'lib/database/migrations/v1_initial_schema.sql',
      );
      _log('Schema loaded: ${schema.length} chars');
    } catch (e) {
      _log('FATAL: Cannot load schema: $e');
      rethrow;
    }

    // Split by semicolon and execute each statement
    // First, remove all SQL comments (lines starting with --)
    final cleanedSchema = schema
        .split('\n')
        .where((line) => !line.trim().startsWith('--'))
        .join('\n');

    final statements = cleanedSchema
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    for (final statement in statements) {
      try {
        await db.execute('$statement;');
      } catch (e) {
        // Skip expected errors for virtual table operations
        // Errors are silently ignored in production
      }
    }

    // Load initial data
    await _loadInitialData(db);
  }

  /// Load initial data from SQL files
  static Future<void> _loadInitialData(Database db) async {
    final dataFiles = [
      'lib/database/data/categories.sql',
      'lib/database/data/emergency_contacts.sql',
      'lib/database/data/thirukkural.sql',
      'lib/database/data/schemes.sql',
      'lib/database/data/schemes_additional.sql',
      'lib/database/data/hospitals.sql',
      'lib/database/data/siddhars.sql',
      'lib/database/data/festivals.sql',
      'lib/database/data/scam_patterns.sql',
      'lib/database/data/cyber_safety_tips.sql',
      'lib/database/data/scholarships.sql',
      'lib/database/data/exams.sql',
      'lib/database/data/legal_rights.sql',
      'lib/database/data/legal_templates.sql',
      'lib/database/data/siddha_medicine.sql',
    ];

    _log('Starting _loadInitialData');

    for (final file in dataFiles) {
      try {
        final sql = await rootBundle.loadString(file);
        _log('Loaded ${file.split('/').last} (${sql.length} chars)');

        // Remove comment lines first, then split by semicolon
        final cleanedSql = sql
            .split('\n')
            .where((line) => !line.trim().startsWith('--'))
            .join('\n');

        final statements = cleanedSql
            .split(';')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty);

        int successCount = 0;
        for (final statement in statements) {
          try {
            await db.execute('$statement;');
            successCount++;
          } catch (e) {
            _log('Statement error in ${file.split('/').last}: $e');
          }
        }
        _log('Executed $successCount statements from ${file.split('/').last}');
      } catch (e) {
        _log('Failed to load ${file.split('/').last}: $e');
      }
    }

    // Verify data loaded
    try {
      final kuralCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM thirukkural',
      );
      _log('Thirukkural count: ${kuralCount.first['count']}');
    } catch (e) {
      _log('Cannot count thirukkural: $e');
    }

    // Populate FTS index for existing data (in case triggers didn't fire)
    await _populateFtsIndex(db);

    _log('_loadInitialData complete');
  }

  /// Populate FTS5 search index for existing data
  static Future<void> _populateFtsIndex(Database db) async {
    _log('Populating FTS index');

    try {
      // Check if FTS is already populated
      final ftsCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM search_index',
      );
      if ((ftsCount.first['count'] as int) > 0) {
        _log('FTS index already populated');
        return;
      }

      // Populate from Thirukkural
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          kural_number,
          'thirukkural',
          'culture',
          athikaram || ' - குறள் ' || kural_number,
          athikaram_english || ' - Kural ' || kural_number,
          verse_full || ' ' || COALESCE(meaning_tamil, ''),
          COALESCE(meaning_english, ''),
          COALESCE(keywords_tamil, '') || ' ' || COALESCE(keywords_english, '')
        FROM thirukkural
      ''');

      // Populate from schemes
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'scheme',
          'govt',
          name_tamil,
          name_english,
          description_tamil || ' ' || COALESCE(how_to_apply_tamil, ''),
          description_english || ' ' || COALESCE(how_to_apply_english, ''),
          COALESCE(department, '') || ' ' || COALESCE(benefit_type, '')
        FROM schemes
      ''');

      // Populate from hospitals
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'hospital',
          'health',
          COALESCE(name_tamil, name_english),
          name_english,
          COALESCE(address, '') || ' ' || COALESCE(city, '') || ' ' || district,
          type || ' ' || COALESCE(specialty, ''),
          district || ' ' || type
        FROM hospitals
      ''');

      // Populate from emergency_contacts
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'emergency_contact',
          'health',
          name_tamil,
          name_english,
          phone || ' ' || COALESCE(alternate_phone, ''),
          type,
          'emergency அவசரம் ' || type || ' ' || COALESCE(district, '')
        FROM emergency_contacts
      ''');

      // Populate from siddhars
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'siddhar',
          'culture',
          name_tamil,
          name_english,
          brief_tamil || ' ' || COALESCE(teachings, ''),
          brief_english || ' ' || COALESCE(expertise, ''),
          'சித்தர் siddhar ' || name_tamil || ' ' || name_english
        FROM siddhars
      ''');

      // Populate from festivals
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'festival',
          'culture',
          name_tamil,
          name_english,
          significance_tamil || ' ' || COALESCE(rituals_tamil, ''),
          significance_english || ' ' || COALESCE(rituals_english, ''),
          'திருவிழா festival ' || COALESCE(type, '') || ' ' || COALESCE(tamil_month, '')
        FROM festivals
      ''');

      // Populate from siddha_medicine
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'siddha_medicine',
          'health',
          name_tamil,
          COALESCE(name_english, name_tamil),
          description_tamil || ' ' || COALESCE(preparation, ''),
          COALESCE(description_english, ''),
          'சித்த மருத்துவம் siddha medicine ' || COALESCE(category, '') || ' ' || COALESCE(traditional_use, '')
        FROM siddha_medicine
      ''');

      // Populate from cyber_safety_tips
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'cyber_safety_tip',
          'security',
          title_tamil,
          title_english,
          tip_tamil,
          tip_english,
          'இணைய பாதுகாப்பு cyber safety ' || COALESCE(category, '')
        FROM cyber_safety_tips
      ''');

      // Populate from exams
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'exam',
          'education',
          COALESCE(name_tamil, name_english),
          name_english,
          COALESCE(eligibility_tamil, '') || ' ' || COALESCE(exam_pattern, ''),
          COALESCE(eligibility_english, ''),
          'தேர்வு exam ' || COALESCE(conducting_body, '') || ' ' || COALESCE(level, '')
        FROM exams
      ''');

      // Populate from legal_rights
      await db.execute('''
        INSERT INTO search_index (content_id, content_type, category_id, title_tamil, title_english, content_tamil, content_english, keywords)
        SELECT
          id,
          'legal_right',
          'legal',
          title_tamil,
          title_english,
          description_tamil || ' ' || COALESCE(how_to_claim_tamil, ''),
          description_english || ' ' || COALESCE(how_to_claim_english, ''),
          'உரிமை rights சட்டம் legal ' || COALESCE(category, '') || ' ' || COALESCE(act_name, '')
        FROM legal_rights
      ''');

      final newCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM search_index',
      );
      _log('FTS index populated with ${newCount.first['count']} entries');
    } catch (e) {
      _log('FTS population error: $e');
    }
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Future migrations go here
    // if (oldVersion < 2) { await _migrateToV2(db); }
  }

  /// Get schema version
  static Future<int> getSchemaVersion() async {
    final db = await database;
    try {
      final result = await db.query(
        'db_info',
        where: 'key = ?',
        whereArgs: ['schema_version'],
      );
      if (result.isNotEmpty) {
        return int.tryParse(result.first['value'] as String) ?? 1;
      }
    } catch (_) {}
    return 1;
  }

  /// Check if database is ready
  static Future<bool> isReady() async {
    try {
      final db = await database;
      final result = await db.query('categories', limit: 1);
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Get all categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return db.query('categories', orderBy: 'sort_order ASC');
  }

  /// Close the database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }

  /// Reset database (for testing)
  static Future<void> reset() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
  }

  // ============================================================================
  // THIRUKKURAL QUERIES
  // ============================================================================

  /// Get Thirukkural by number
  static Future<Map<String, dynamic>?> getKuralByNumber(int number) async {
    // Validate kural number range (1-1330)
    final validNumber = _validateIntRange(number, 1, 1330);
    if (validNumber == null) {
      return null;
    }

    final db = await database;
    final result = await db.query(
      'thirukkural',
      where: 'kural_number = ?',
      whereArgs: [validNumber],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get Thirukkural by Athikaram
  static Future<List<Map<String, dynamic>>> getKuralsByAthikaram(
    int athikaramNumber,
  ) async {
    // Validate athikaram number range (1-133)
    final validNumber = _validateIntRange(athikaramNumber, 1, 133);
    if (validNumber == null) {
      return [];
    }

    final db = await database;
    return db.query(
      'thirukkural',
      where: 'athikaram_number = ?',
      whereArgs: [validNumber],
      orderBy: 'kural_number ASC',
    );
  }

  /// Get all Athikarams
  static Future<List<Map<String, dynamic>>> getAllAthikarams() async {
    final db = await database;
    return db.rawQuery('''
      SELECT DISTINCT athikaram_number, athikaram, athikaram_english, paal, paal_english
      FROM thirukkural
      ORDER BY athikaram_number ASC
    ''');
  }

  /// Search Thirukkural
  static Future<List<Map<String, dynamic>>> searchKurals(String query) async {
    // Validate and sanitize input
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) {
      return [];
    }

    final db = await database;
    final searchTerm = '%$sanitized%';
    return db.query(
      'thirukkural',
      where: '''
        verse_full LIKE ? OR
        meaning_tamil LIKE ? OR
        meaning_english LIKE ? OR
        keywords_tamil LIKE ? OR
        keywords_english LIKE ?
      ''',
      whereArgs: [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm],
      orderBy: 'kural_number ASC',
      limit: 20,
    );
  }

  // ============================================================================
  // SCHEMES QUERIES
  // ============================================================================

  /// Get all schemes
  static Future<List<Map<String, dynamic>>> getAllSchemes({
    String? level,
    bool activeOnly = true,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (level != null && activeOnly) {
      where = 'level = ? AND is_active = 1';
      whereArgs = [level];
    } else if (level != null) {
      where = 'level = ?';
      whereArgs = [level];
    } else if (activeOnly) {
      where = 'is_active = 1';
    }

    return db.query('schemes', where: where, whereArgs: whereArgs);
  }

  /// Get scheme by ID
  static Future<Map<String, dynamic>?> getSchemeById(String id) async {
    final db = await database;
    final result = await db.query('schemes', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  /// Get scheme eligibility
  static Future<List<Map<String, dynamic>>> getSchemeEligibility(
    String schemeId,
  ) async {
    final db = await database;
    return db.query(
      'scheme_eligibility',
      where: 'scheme_id = ?',
      whereArgs: [schemeId],
    );
  }

  /// Get scheme documents
  static Future<List<Map<String, dynamic>>> getSchemeDocuments(
    String schemeId,
  ) async {
    final db = await database;
    return db.query(
      'scheme_documents',
      where: 'scheme_id = ?',
      whereArgs: [schemeId],
      orderBy: 'is_mandatory DESC',
    );
  }

  // ============================================================================
  // EMERGENCY CONTACTS QUERIES
  // ============================================================================

  /// Get all emergency contacts
  static Future<List<Map<String, dynamic>>> getEmergencyContacts({
    String? type,
    String? district,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (type != null && district != null) {
      where = 'type = ? AND (district = ? OR is_national = 1)';
      whereArgs = [type, district];
    } else if (type != null) {
      where = 'type = ?';
      whereArgs = [type];
    } else if (district != null) {
      where = 'district = ? OR is_national = 1';
      whereArgs = [district];
    }

    return db.query('emergency_contacts', where: where, whereArgs: whereArgs);
  }

  /// Get national emergency numbers
  static Future<List<Map<String, dynamic>>>
  getNationalEmergencyNumbers() async {
    final db = await database;
    return db.query(
      'emergency_contacts',
      where: 'is_national = 1',
      orderBy: 'type ASC',
    );
  }

  // ============================================================================
  // HOSPITALS QUERIES
  // ============================================================================

  /// Get hospitals by district
  static Future<List<Map<String, dynamic>>> getHospitalsByDistrict(
    String district, {
    String? type,
    bool cmchisOnly = false,
  }) async {
    final db = await database;
    final conditions = <String>['district = ?'];
    final args = <dynamic>[district];

    if (type != null) {
      conditions.add('type = ?');
      args.add(type);
    }
    if (cmchisOnly) {
      conditions.add('accepts_cmchis = 1');
    }

    return db.query(
      'hospitals',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'name_english ASC',
    );
  }

  /// Search hospitals
  static Future<List<Map<String, dynamic>>> searchHospitals(
    String query,
  ) async {
    // Validate and sanitize input
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) {
      return [];
    }

    final db = await database;
    final searchTerm = '%$sanitized%';
    return db.query(
      'hospitals',
      where: 'name_english LIKE ? OR name_tamil LIKE ? OR city LIKE ?',
      whereArgs: [searchTerm, searchTerm, searchTerm],
      limit: 20,
    );
  }

  // ============================================================================
  // FULL-TEXT SEARCH
  // ============================================================================

  /// Search across all content using FTS5
  static Future<List<Map<String, dynamic>>> fullTextSearch(
    String query, {
    String? categoryId,
    int limit = 20,
  }) async {
    // Validate and sanitize input
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) {
      return [];
    }

    // Sanitize FTS5 special characters to prevent query injection
    final ftsQuery = _sanitizeFtsQuery(sanitized);
    if (ftsQuery.isEmpty) {
      return [];
    }

    // Clamp limit to prevent DoS
    final safeLimit = limit.clamp(1, _maxSearchResults);

    final db = await database;

    String sql = '''
      SELECT content_id, content_type, category_id, title_tamil, title_english,
             snippet(search_index, 5, '<b>', '</b>', '...', 32) as snippet
      FROM search_index
      WHERE search_index MATCH ?
    ''';

    final args = <dynamic>[ftsQuery];

    if (categoryId != null) {
      sql += ' AND category_id = ?';
      args.add(_sanitizeQuery(categoryId, maxLength: 50));
    }

    sql += ' ORDER BY rank LIMIT ?';
    args.add(safeLimit);

    try {
      return db.rawQuery(sql, args);
    } catch (e) {
      // Fallback if FTS fails
      return [];
    }
  }

  /// Sanitize FTS5 query to prevent query injection
  static String _sanitizeFtsQuery(String query) {
    // Remove FTS5 special operators that could be abused
    // Keep alphanumeric, Tamil unicode, spaces, and basic punctuation
    return query
        .replaceAll(RegExp(r'["\*\-\+\(\)\{\}\[\]\^~]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ============================================================================
  // QUERY ROUTING
  // ============================================================================

  /// Get query patterns for routing
  static Future<List<Map<String, dynamic>>> getQueryPatterns() async {
    final db = await database;
    return db.query('query_patterns', orderBy: 'priority DESC');
  }

  // ============================================================================
  // SIDDHARS QUERIES
  // ============================================================================

  /// Get all Siddhars
  static Future<List<Map<String, dynamic>>> getAllSiddhars() async {
    final db = await database;
    return db.query('siddhars', orderBy: 'id ASC');
  }

  /// Get Siddhar by name
  static Future<List<Map<String, dynamic>>> searchSiddhars(
    String query,
  ) async {
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) return [];

    final db = await database;
    final searchTerm = '%$sanitized%';
    return db.query(
      'siddhars',
      where: 'name_tamil LIKE ? OR name_english LIKE ? OR expertise LIKE ?',
      whereArgs: [searchTerm, searchTerm, searchTerm],
      limit: 20,
    );
  }

  // ============================================================================
  // FESTIVALS QUERIES
  // ============================================================================

  /// Get all festivals
  static Future<List<Map<String, dynamic>>> getAllFestivals({
    String? type,
  }) async {
    final db = await database;
    if (type != null) {
      return db.query(
        'festivals',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'id ASC',
      );
    }
    return db.query('festivals', orderBy: 'id ASC');
  }

  /// Search festivals
  static Future<List<Map<String, dynamic>>> searchFestivals(
    String query,
  ) async {
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) return [];

    final db = await database;
    final searchTerm = '%$sanitized%';
    return db.query(
      'festivals',
      where:
          'name_tamil LIKE ? OR name_english LIKE ? OR significance_tamil LIKE ?',
      whereArgs: [searchTerm, searchTerm, searchTerm],
      limit: 20,
    );
  }

  // ============================================================================
  // SCAM PATTERNS QUERIES
  // ============================================================================

  /// Get all scam patterns
  static Future<List<Map<String, dynamic>>> getAllScamPatterns({
    String? type,
  }) async {
    final db = await database;
    if (type != null) {
      return db.query('scam_patterns', where: 'type = ?', whereArgs: [type]);
    }
    return db.query('scam_patterns');
  }

  /// Search scam patterns
  static Future<List<Map<String, dynamic>>> searchScamPatterns(
    String query,
  ) async {
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) return [];

    final db = await database;
    final searchTerm = '%$sanitized%';
    return db.query(
      'scam_patterns',
      where: '''
        name_tamil LIKE ? OR name_english LIKE ? OR
        description_tamil LIKE ? OR red_flags_tamil LIKE ? OR
        example_messages LIKE ?
      ''',
      whereArgs: [
        searchTerm,
        searchTerm,
        searchTerm,
        searchTerm,
        searchTerm,
      ],
      limit: 20,
    );
  }

  // ============================================================================
  // CYBER SAFETY TIPS QUERIES
  // ============================================================================

  /// Get all cyber safety tips
  static Future<List<Map<String, dynamic>>> getCyberSafetyTips({
    String? category,
  }) async {
    final db = await database;
    if (category != null) {
      return db.query(
        'cyber_safety_tips',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'priority ASC',
      );
    }
    return db.query('cyber_safety_tips', orderBy: 'priority ASC');
  }

  // ============================================================================
  // SCHOLARSHIPS QUERIES
  // ============================================================================

  /// Get all scholarships
  static Future<List<Map<String, dynamic>>> getAllScholarships({
    String? educationLevel,
    String? category,
    bool activeOnly = true,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (educationLevel != null) {
      conditions.add('education_level = ?');
      args.add(educationLevel);
    }
    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }
    if (activeOnly) {
      conditions.add('is_active = 1');
    }

    return db.query(
      'scholarships',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
    );
  }

  /// Search scholarships
  static Future<List<Map<String, dynamic>>> searchScholarships(
    String query,
  ) async {
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) return [];

    final db = await database;
    final searchTerm = '%$sanitized%';
    return db.query(
      'scholarships',
      where: 'name_tamil LIKE ? OR name_english LIKE ? OR description_tamil LIKE ?',
      whereArgs: [searchTerm, searchTerm, searchTerm],
      limit: 20,
    );
  }

  // ============================================================================
  // EXAMS QUERIES
  // ============================================================================

  /// Get all exams
  static Future<List<Map<String, dynamic>>> getAllExams({
    String? level,
  }) async {
    final db = await database;
    if (level != null) {
      return db.query('exams', where: 'level = ?', whereArgs: [level]);
    }
    return db.query('exams');
  }

  /// Get exam by ID
  static Future<Map<String, dynamic>?> getExamById(String id) async {
    final db = await database;
    final result = await db.query('exams', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // ============================================================================
  // LEGAL QUERIES
  // ============================================================================

  /// Get all legal rights
  static Future<List<Map<String, dynamic>>> getLegalRights({
    String? category,
  }) async {
    final db = await database;
    if (category != null) {
      return db.query(
        'legal_rights',
        where: 'category = ?',
        whereArgs: [category],
      );
    }
    return db.query('legal_rights');
  }

  /// Search legal rights
  static Future<List<Map<String, dynamic>>> searchLegalRights(
    String query,
  ) async {
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) return [];

    final db = await database;
    final searchTerm = '%$sanitized%';
    return db.query(
      'legal_rights',
      where: '''
        title_tamil LIKE ? OR title_english LIKE ? OR
        description_tamil LIKE ? OR act_name LIKE ?
      ''',
      whereArgs: [searchTerm, searchTerm, searchTerm, searchTerm],
      limit: 20,
    );
  }

  /// Get all legal templates
  static Future<List<Map<String, dynamic>>> getLegalTemplates({
    String? category,
  }) async {
    final db = await database;
    if (category != null) {
      return db.query(
        'legal_templates',
        where: 'category = ?',
        whereArgs: [category],
      );
    }
    return db.query('legal_templates');
  }

  /// Get legal template by ID
  static Future<Map<String, dynamic>?> getLegalTemplateById(String id) async {
    final db = await database;
    final result = await db.query(
      'legal_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ============================================================================
  // SIDDHA MEDICINE QUERIES
  // ============================================================================

  /// Get all Siddha medicine entries
  static Future<List<Map<String, dynamic>>> getSiddhaMedicine({
    String? category,
  }) async {
    final db = await database;
    if (category != null) {
      return db.query(
        'siddha_medicine',
        where: 'category = ?',
        whereArgs: [category],
      );
    }
    return db.query('siddha_medicine');
  }

  /// Search Siddha medicine
  static Future<List<Map<String, dynamic>>> searchSiddhaMedicine(
    String query,
  ) async {
    final sanitized = _sanitizeQuery(query, maxLength: 200);
    if (sanitized.isEmpty) return [];

    final db = await database;
    final searchTerm = '%$sanitized%';
    return db.query(
      'siddha_medicine',
      where: '''
        name_tamil LIKE ? OR name_english LIKE ? OR
        description_tamil LIKE ? OR traditional_use LIKE ?
      ''',
      whereArgs: [searchTerm, searchTerm, searchTerm, searchTerm],
      limit: 20,
    );
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get database statistics
  static Future<Map<String, int>> getStats() async {
    final db = await database;
    final stats = <String, int>{};

    final tables = [
      'thirukkural',
      'siddhars',
      'festivals',
      'schemes',
      'hospitals',
      'emergency_contacts',
      'scam_patterns',
      'cyber_safety_tips',
      'scholarships',
      'exams',
      'legal_rights',
      'legal_templates',
      'siddha_medicine',
    ];

    for (final table in tables) {
      try {
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $table',
        );
        stats[table] = result.first['count'] as int;
      } catch (_) {
        stats[table] = 0;
      }
    }

    return stats;
  }
}
