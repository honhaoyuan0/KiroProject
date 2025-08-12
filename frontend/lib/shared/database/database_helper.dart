import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'screen_time_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create app_groups table
    await db.execute('''
      CREATE TABLE app_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        app_packages TEXT NOT NULL,
        time_limit_minutes INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create timer_sessions table
    await db.execute('''
      CREATE TABLE timer_sessions (
        group_id TEXT PRIMARY KEY,
        start_time INTEGER NOT NULL,
        elapsed_time_seconds INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        last_pause_time INTEGER,
        FOREIGN KEY (group_id) REFERENCES app_groups (id) ON DELETE CASCADE
      )
    ''');

    // Create usage_stats table
    await db.execute('''
      CREATE TABLE usage_stats (
        app_package TEXT PRIMARY KEY,
        group_id TEXT,
        daily_usage_seconds INTEGER NOT NULL DEFAULT 0,
        weekly_usage_seconds INTEGER NOT NULL DEFAULT 0,
        monthly_usage_seconds INTEGER NOT NULL DEFAULT 0,
        last_used INTEGER NOT NULL,
        FOREIGN KEY (group_id) REFERENCES app_groups (id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_app_groups_active ON app_groups (is_active)');
    await db.execute('CREATE INDEX idx_timer_sessions_active ON timer_sessions (is_active)');
    await db.execute('CREATE INDEX idx_usage_stats_group ON usage_stats (group_id)');
  }

  // App Groups CRUD operations
  Future<int> insertAppGroup(AppGroup appGroup) async {
    final db = await database;
    return await db.insert('app_groups', appGroup.toMap());
  }

  Future<List<AppGroup>> getAllAppGroups() async {
    final db = await database;
    final maps = await db.query('app_groups', orderBy: 'created_at DESC');
    return maps.map((map) => AppGroup.fromMap(map)).toList();
  }

  Future<List<AppGroup>> getActiveAppGroups() async {
    final db = await database;
    final maps = await db.query(
      'app_groups',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => AppGroup.fromMap(map)).toList();
  }

  Future<AppGroup?> getAppGroupById(String id) async {
    final db = await database;
    final maps = await db.query(
      'app_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AppGroup.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAppGroup(AppGroup appGroup) async {
    final db = await database;
    return await db.update(
      'app_groups',
      appGroup.toMap(),
      where: 'id = ?',
      whereArgs: [appGroup.id],
    );
  }

  Future<int> deleteAppGroup(String id) async {
    final db = await database;
    return await db.delete(
      'app_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Timer Sessions CRUD operations
  Future<int> insertOrUpdateTimerSession(TimerSession session) async {
    final db = await database;
    return await db.insert(
      'timer_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TimerSession?> getTimerSession(String groupId) async {
    final db = await database;
    final maps = await db.query(
      'timer_sessions',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    if (maps.isNotEmpty) {
      return TimerSession.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TimerSession>> getActiveTimerSessions() async {
    final db = await database;
    final maps = await db.query(
      'timer_sessions',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return maps.map((map) => TimerSession.fromMap(map)).toList();
  }

  Future<int> deleteTimerSession(String groupId) async {
    final db = await database;
    return await db.delete(
      'timer_sessions',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
  }

  // Usage Stats CRUD operations
  Future<int> insertOrUpdateUsageStats(UsageStats stats) async {
    final db = await database;
    return await db.insert(
      'usage_stats',
      stats.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UsageStats?> getUsageStats(String appPackage) async {
    final db = await database;
    final maps = await db.query(
      'usage_stats',
      where: 'app_package = ?',
      whereArgs: [appPackage],
    );
    if (maps.isNotEmpty) {
      return UsageStats.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UsageStats>> getAllUsageStats() async {
    final db = await database;
    final maps = await db.query('usage_stats', orderBy: 'last_used DESC');
    return maps.map((map) => UsageStats.fromMap(map)).toList();
  }

  Future<List<UsageStats>> getUsageStatsByGroup(String groupId) async {
    final db = await database;
    final maps = await db.query(
      'usage_stats',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'last_used DESC',
    );
    return maps.map((map) => UsageStats.fromMap(map)).toList();
  }

  Future<int> deleteUsageStats(String appPackage) async {
    final db = await database;
    return await db.delete(
      'usage_stats',
      where: 'app_package = ?',
      whereArgs: [appPackage],
    );
  }

  // Utility methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('usage_stats');
    await db.delete('timer_sessions');
    await db.delete('app_groups');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Transaction support for complex operations
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
}