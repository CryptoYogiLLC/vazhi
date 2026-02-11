/// Database Migration Framework
///
/// Handles versioned database migrations with tracking and rollback support.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

/// Exception thrown when a migration fails
class MigrationException implements Exception {
  final String message;
  final int version;
  final Object? originalError;

  MigrationException(this.message, this.version, [this.originalError]);

  @override
  String toString() =>
      'MigrationException: Migration v$version failed - $message';
}

/// Status of a migration
enum MigrationStatus { pending, applied, failed, rolledBack }

/// A single migration record
class MigrationRecord {
  final int version;
  final String name;
  final DateTime appliedAt;
  final int durationMs;
  final MigrationStatus status;

  MigrationRecord({
    required this.version,
    required this.name,
    required this.appliedAt,
    required this.durationMs,
    required this.status,
  });

  factory MigrationRecord.fromMap(Map<String, dynamic> map) {
    return MigrationRecord(
      version: map['version'] as int,
      name: map['name'] as String,
      appliedAt: DateTime.parse(map['applied_at'] as String),
      durationMs: map['duration_ms'] as int? ?? 0,
      status: MigrationStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => MigrationStatus.pending,
      ),
    );
  }
}

/// Handles database migrations
class MigrationRunner {
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('MigrationRunner: $message');
    }
  }

  /// Initialize migration tracking table
  static Future<void> initMigrationTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        applied_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        duration_ms INTEGER DEFAULT 0,
        status TEXT CHECK(status IN ('pending', 'applied', 'failed', 'rolled_back')) DEFAULT 'pending'
      )
    ''');
  }

  /// Get the current database version from migrations table
  static Future<int> getCurrentVersion(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT MAX(version) as version FROM schema_migrations
        WHERE status = 'applied'
      ''');
      if (result.isNotEmpty && result.first['version'] != null) {
        return result.first['version'] as int;
      }
    } catch (e) {
      _log('Could not get current version: $e');
    }
    return 0;
  }

  /// Get all migration records
  static Future<List<MigrationRecord>> getMigrationHistory(Database db) async {
    try {
      final results = await db.query(
        'schema_migrations',
        orderBy: 'version ASC',
      );
      return results.map((r) => MigrationRecord.fromMap(r)).toList();
    } catch (e) {
      _log('Could not get migration history: $e');
      return [];
    }
  }

  /// Check if a specific version has been applied
  static Future<bool> isMigrationApplied(Database db, int version) async {
    try {
      final result = await db.query(
        'schema_migrations',
        where: 'version = ? AND status = ?',
        whereArgs: [version, 'applied'],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Run all pending migrations up to targetVersion
  static Future<void> runMigrations(
    Database db, {
    required int targetVersion,
    String migrationPath = 'lib/database/migrations',
  }) async {
    await initMigrationTable(db);
    final currentVersion = await getCurrentVersion(db);

    _log('Current version: $currentVersion, target: $targetVersion');

    if (currentVersion >= targetVersion) {
      _log('No migrations needed');
      return;
    }

    for (int v = currentVersion + 1; v <= targetVersion; v++) {
      final alreadyApplied = await isMigrationApplied(db, v);
      if (alreadyApplied) {
        _log('Migration v$v already applied, skipping');
        continue;
      }

      await _executeMigration(db, v, migrationPath);
    }

    _log('Migrations complete');
  }

  /// Execute a single migration
  static Future<void> _executeMigration(
    Database db,
    int version,
    String migrationPath,
  ) async {
    final startTime = DateTime.now();
    final migrationName = 'v${version}_migration';

    _log('Starting migration v$version');

    // Record pending migration
    await db.insert('schema_migrations', {
      'version': version,
      'name': migrationName,
      'status': 'pending',
    });

    try {
      // Try to load migration SQL file
      final sqlFile = await _findMigrationFile(version, migrationPath);
      if (sqlFile != null) {
        await _executeSqlFile(db, sqlFile);
      } else {
        // Check for Dart migration
        final migrated = await _executeDartMigration(db, version);
        if (!migrated) {
          throw MigrationException(
            'No migration found for version $version',
            version,
          );
        }
      }

      // Record success
      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      await db.update(
        'schema_migrations',
        {
          'status': 'applied',
          'duration_ms': durationMs,
          'applied_at': DateTime.now().toIso8601String(),
        },
        where: 'version = ?',
        whereArgs: [version],
      );

      _log('Migration v$version completed in ${durationMs}ms');
    } catch (e) {
      // Record failure
      await db.update(
        'schema_migrations',
        {'status': 'failed'},
        where: 'version = ?',
        whereArgs: [version],
      );

      throw MigrationException('Migration v$version failed', version, e);
    }
  }

  /// Find migration SQL file for version
  static Future<String?> _findMigrationFile(
    int version,
    String migrationPath,
  ) async {
    // Try different naming patterns
    final patterns = [
      '$migrationPath/v$version.sql',
      '$migrationPath/v${version}_migration.sql',
    ];

    for (final path in patterns) {
      try {
        final sql = await rootBundle.loadString(path);
        return sql;
      } catch (_) {
        // File not found, try next pattern
      }
    }

    return null;
  }

  /// Execute SQL file statements
  static Future<void> _executeSqlFile(Database db, String sql) async {
    // Remove comments
    final cleanedSql = sql
        .split('\n')
        .where((line) => !line.trim().startsWith('--'))
        .join('\n');

    // Split and execute statements
    final statements = cleanedSql
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    for (final statement in statements) {
      await db.execute('$statement;');
    }
  }

  /// Execute Dart-based migration (for complex migrations)
  static Future<bool> _executeDartMigration(Database db, int version) async {
    // Register Dart migrations here
    final migrations = <int, Future<void> Function(Database)>{
      // Example: 2: _migrateV2,
    };

    final migrationFn = migrations[version];
    if (migrationFn != null) {
      await migrationFn(db);
      return true;
    }

    return false;
  }

  /// Verify database integrity after migrations
  static Future<bool> verifyIntegrity(Database db) async {
    try {
      final result = await db.rawQuery('PRAGMA integrity_check');
      final status = result.first['integrity_check'] as String?;
      return status == 'ok';
    } catch (e) {
      _log('Integrity check failed: $e');
      return false;
    }
  }
}
