import 'package:wise_screen/core/models/app_group.dart';
import 'package:wise_screen/core/models/timer_session.dart';
import 'package:wise_screen/core/models/usage_stats.dart';
import 'package:wise_screen/shared/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mock implementation of DatabaseHelper for testing
class MockDatabaseHelper implements DatabaseHelper {
  final Map<String, AppGroup> _appGroups = {};
  final Map<String, TimerSession> _timerSessions = {};
  final Map<String, UsageStats> _usageStats = {};

  @override
  Future<Database> get database async {
    // Return a mock database for testing
    return await databaseFactoryFfi.openDatabase(':memory:');
  }

  @override
  Future<void> insertAppGroup(AppGroup appGroup) async {
    _appGroups[appGroup.id] = appGroup;
  }

  @override
  Future<void> updateAppGroup(AppGroup appGroup) async {
    _appGroups[appGroup.id] = appGroup;
  }

  @override
  Future<void> deleteAppGroup(String groupId) async {
    _appGroups.remove(groupId);
    _timerSessions.remove(groupId);
  }

  @override
  Future<AppGroup?> getAppGroup(String groupId) async {
    return _appGroups[groupId];
  }

  @override
  Future<List<AppGroup>> getAllAppGroups() async {
    return _appGroups.values.toList();
  }

  @override
  Future<void> insertOrUpdateTimerSession(TimerSession session) async {
    _timerSessions[session.groupId] = session;
  }

  @override
  Future<TimerSession?> getTimerSession(String groupId) async {
    return _timerSessions[groupId];
  }

  @override
  Future<List<TimerSession>> getAllTimerSessions() async {
    return _timerSessions.values.toList();
  }

  @override
  Future<void> deleteTimerSession(String groupId) async {
    _timerSessions.remove(groupId);
  }

  @override
  Future<void> insertUsageStats(UsageStats stats) async {
    _usageStats[stats.appPackage] = stats;
  }

  @override
  Future<void> updateUsageStats(UsageStats stats) async {
    _usageStats[stats.appPackage] = stats;
  }

  @override
  Future<UsageStats?> getUsageStats(String appPackage) async {
    return _usageStats[appPackage];
  }

  @override
  Future<List<UsageStats>> getAllUsageStats() async {
    return _usageStats.values.toList();
  }

  @override
  Future<List<UsageStats>> getUsageStatsByGroup(String groupId) async {
    return _usageStats.values
        .where((stats) => stats.groupId == groupId)
        .toList();
  }

  @override
  Future<void> deleteUsageStats(String appPackage) async {
    _usageStats.remove(appPackage);
  }

  @override
  Future<void> clearAllData() async {
    _appGroups.clear();
    _timerSessions.clear();
    _usageStats.clear();
  }

  @override
  Future<void> close() async {
    // No-op for mock
  }

  // Helper methods for testing
  void addMockAppGroup(AppGroup appGroup) {
    _appGroups[appGroup.id] = appGroup;
  }

  void addMockTimerSession(TimerSession session) {
    _timerSessions[session.groupId] = session;
  }

  void addMockUsageStats(UsageStats stats) {
    _usageStats[stats.appPackage] = stats;
  }

  void clearMockData() {
    _appGroups.clear();
    _timerSessions.clear();
    _usageStats.clear();
  }
}

/// Helper function to create test app groups
AppGroup createTestAppGroup({
  String? id,
  String? name,
  List<String>? appPackages,
  Duration? timeLimit,
  DateTime? createdAt,
  bool? isActive,
}) {
  return AppGroup(
    id: id ?? 'test-group-${DateTime.now().millisecondsSinceEpoch}',
    name: name ?? 'Test Group',
    appPackages: appPackages ?? ['com.example.app1', 'com.example.app2'],
    timeLimit: timeLimit ?? const Duration(minutes: 30),
    createdAt: createdAt ?? DateTime.now(),
    isActive: isActive ?? true,
  );
}

/// Helper function to create test timer sessions
TimerSession createTestTimerSession({
  String? groupId,
  DateTime? startTime,
  Duration? elapsedTime,
  bool? isActive,
  DateTime? lastPauseTime,
}) {
  return TimerSession(
    groupId: groupId ?? 'test-group-1',
    startTime: startTime ?? DateTime.now(),
    elapsedTime: elapsedTime ?? Duration.zero,
    isActive: isActive ?? false,
    lastPauseTime: lastPauseTime,
  );
}

/// Helper function to create test usage stats
UsageStats createTestUsageStats({
  String? appPackage,
  String? groupId,
  Duration? dailyUsage,
  Duration? weeklyUsage,
  Duration? monthlyUsage,
  DateTime? lastUsed,
}) {
  return UsageStats(
    appPackage: appPackage ?? 'com.example.app',
    groupId: groupId ?? 'test-group-1',
    dailyUsage: dailyUsage ?? const Duration(minutes: 30),
    weeklyUsage: weeklyUsage ?? const Duration(hours: 3),
    monthlyUsage: monthlyUsage ?? const Duration(hours: 12),
    lastUsed: lastUsed ?? DateTime.now(),
  );
}