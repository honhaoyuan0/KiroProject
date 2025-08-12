import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wise_screen/shared/database/database_helper.dart';
import 'package:wise_screen/core/models/models.dart';

void main() {
  group('DatabaseHelper', () {
    late DatabaseHelper databaseHelper;
    late AppGroup testAppGroup;
    late TimerSession testTimerSession;
    late UsageStats testUsageStats;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      databaseHelper = DatabaseHelper();
      
      // Create test data
      final now = DateTime.now();
      testAppGroup = AppGroup(
        id: 'test-group-1',
        name: 'Social Media',
        appPackages: ['com.instagram.android', 'com.twitter.android'],
        timeLimit: const Duration(minutes: 30),
        createdAt: now,
        isActive: true,
      );

      testTimerSession = TimerSession(
        groupId: 'test-group-1',
        startTime: now,
        elapsedTime: const Duration(minutes: 15),
        isActive: true,
        lastPauseTime: now.add(const Duration(minutes: 10)),
      );

      testUsageStats = UsageStats(
        appPackage: 'com.instagram.android',
        groupId: 'test-group-1',
        dailyUsage: const Duration(hours: 2),
        weeklyUsage: const Duration(hours: 14),
        monthlyUsage: const Duration(hours: 56),
        lastUsed: now,
      );

      // Clear any existing data
      await databaseHelper.clearAllData();
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    group('AppGroup operations', () {
      test('should insert and retrieve app group', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        final retrieved = await databaseHelper.getAppGroupById(testAppGroup.id);

        expect(retrieved, isNotNull);
        expect(retrieved!.id, testAppGroup.id);
        expect(retrieved.name, testAppGroup.name);
        expect(retrieved.appPackages, testAppGroup.appPackages);
        expect(retrieved.timeLimit, testAppGroup.timeLimit);
        expect(retrieved.isActive, testAppGroup.isActive);
      });

      test('should get all app groups', () async {
        final group2 = testAppGroup.copyWith(
          id: 'test-group-2',
          name: 'Entertainment',
        );

        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertAppGroup(group2);

        final allGroups = await databaseHelper.getAllAppGroups();
        expect(allGroups.length, 2);
        expect(allGroups.map((g) => g.id), containsAll(['test-group-1', 'test-group-2']));
      });

      test('should get only active app groups', () async {
        final inactiveGroup = testAppGroup.copyWith(
          id: 'inactive-group',
          isActive: false,
        );

        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertAppGroup(inactiveGroup);

        final activeGroups = await databaseHelper.getActiveAppGroups();
        expect(activeGroups.length, 1);
        expect(activeGroups.first.id, testAppGroup.id);
        expect(activeGroups.first.isActive, true);
      });

      test('should update app group', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        
        final updatedGroup = testAppGroup.copyWith(
          name: 'Updated Social Media',
          timeLimit: const Duration(minutes: 45),
        );

        await databaseHelper.updateAppGroup(updatedGroup);
        final retrieved = await databaseHelper.getAppGroupById(testAppGroup.id);

        expect(retrieved!.name, 'Updated Social Media');
        expect(retrieved.timeLimit, const Duration(minutes: 45));
      });

      test('should delete app group', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.deleteAppGroup(testAppGroup.id);

        final retrieved = await databaseHelper.getAppGroupById(testAppGroup.id);
        expect(retrieved, isNull);
      });
    });

    group('TimerSession operations', () {
      test('should insert and retrieve timer session', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateTimerSession(testTimerSession);

        final retrieved = await databaseHelper.getTimerSession(testTimerSession.groupId);

        expect(retrieved, isNotNull);
        expect(retrieved!.groupId, testTimerSession.groupId);
        expect(retrieved.elapsedTime, testTimerSession.elapsedTime);
        expect(retrieved.isActive, testTimerSession.isActive);
      });

      test('should update existing timer session', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateTimerSession(testTimerSession);

        final updatedSession = testTimerSession.copyWith(
          elapsedTime: const Duration(minutes: 25),
          isActive: false,
        );

        await databaseHelper.insertOrUpdateTimerSession(updatedSession);
        final retrieved = await databaseHelper.getTimerSession(testTimerSession.groupId);

        expect(retrieved!.elapsedTime, const Duration(minutes: 25));
        expect(retrieved.isActive, false);
      });

      test('should get active timer sessions', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        
        final group2 = testAppGroup.copyWith(id: 'test-group-2');
        await databaseHelper.insertAppGroup(group2);

        final activeSession = testTimerSession;
        final inactiveSession = TimerSession(
          groupId: 'test-group-2',
          startTime: DateTime.now(),
          elapsedTime: const Duration(minutes: 10),
          isActive: false,
        );

        await databaseHelper.insertOrUpdateTimerSession(activeSession);
        await databaseHelper.insertOrUpdateTimerSession(inactiveSession);

        final activeSessions = await databaseHelper.getActiveTimerSessions();
        expect(activeSessions.length, 1);
        expect(activeSessions.first.groupId, activeSession.groupId);
        expect(activeSessions.first.isActive, true);
      });

      test('should delete timer session', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateTimerSession(testTimerSession);
        await databaseHelper.deleteTimerSession(testTimerSession.groupId);

        final retrieved = await databaseHelper.getTimerSession(testTimerSession.groupId);
        expect(retrieved, isNull);
      });
    });

    group('UsageStats operations', () {
      test('should insert and retrieve usage stats', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateUsageStats(testUsageStats);

        final retrieved = await databaseHelper.getUsageStats(testUsageStats.appPackage);

        expect(retrieved, isNotNull);
        expect(retrieved!.appPackage, testUsageStats.appPackage);
        expect(retrieved.groupId, testUsageStats.groupId);
        expect(retrieved.dailyUsage, testUsageStats.dailyUsage);
        expect(retrieved.weeklyUsage, testUsageStats.weeklyUsage);
        expect(retrieved.monthlyUsage, testUsageStats.monthlyUsage);
      });

      test('should update existing usage stats', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateUsageStats(testUsageStats);

        final updatedStats = testUsageStats.copyWith(
          dailyUsage: const Duration(hours: 3),
          weeklyUsage: const Duration(hours: 20),
        );

        await databaseHelper.insertOrUpdateUsageStats(updatedStats);
        final retrieved = await databaseHelper.getUsageStats(testUsageStats.appPackage);

        expect(retrieved!.dailyUsage, const Duration(hours: 3));
        expect(retrieved.weeklyUsage, const Duration(hours: 20));
      });

      test('should get all usage stats', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        
        final stats2 = UsageStats(
          appPackage: 'com.twitter.android',
          groupId: 'test-group-1',
          dailyUsage: const Duration(hours: 1),
          weeklyUsage: const Duration(hours: 7),
          monthlyUsage: const Duration(hours: 28),
          lastUsed: DateTime.now(),
        );

        await databaseHelper.insertOrUpdateUsageStats(testUsageStats);
        await databaseHelper.insertOrUpdateUsageStats(stats2);

        final allStats = await databaseHelper.getAllUsageStats();
        expect(allStats.length, 2);
        expect(allStats.map((s) => s.appPackage), 
               containsAll(['com.instagram.android', 'com.twitter.android']));
      });

      test('should get usage stats by group', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        
        final group2 = testAppGroup.copyWith(id: 'test-group-2');
        await databaseHelper.insertAppGroup(group2);

        final statsGroup1 = testUsageStats;
        final statsGroup2 = UsageStats(
          appPackage: 'com.youtube.android',
          groupId: 'test-group-2',
          dailyUsage: const Duration(hours: 1),
          weeklyUsage: const Duration(hours: 7),
          monthlyUsage: const Duration(hours: 28),
          lastUsed: DateTime.now(),
        );

        await databaseHelper.insertOrUpdateUsageStats(statsGroup1);
        await databaseHelper.insertOrUpdateUsageStats(statsGroup2);

        final group1Stats = await databaseHelper.getUsageStatsByGroup('test-group-1');
        expect(group1Stats.length, 1);
        expect(group1Stats.first.appPackage, 'com.instagram.android');

        final group2Stats = await databaseHelper.getUsageStatsByGroup('test-group-2');
        expect(group2Stats.length, 1);
        expect(group2Stats.first.appPackage, 'com.youtube.android');
      });

      test('should delete usage stats', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateUsageStats(testUsageStats);
        await databaseHelper.deleteUsageStats(testUsageStats.appPackage);

        final retrieved = await databaseHelper.getUsageStats(testUsageStats.appPackage);
        expect(retrieved, isNull);
      });
    });

    group('Utility operations', () {
      test('should clear all data', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateTimerSession(testTimerSession);
        await databaseHelper.insertOrUpdateUsageStats(testUsageStats);

        await databaseHelper.clearAllData();

        final groups = await databaseHelper.getAllAppGroups();
        final sessions = await databaseHelper.getActiveTimerSessions();
        final stats = await databaseHelper.getAllUsageStats();

        expect(groups, isEmpty);
        expect(sessions, isEmpty);
        expect(stats, isEmpty);
      });

      test('should support transactions', () async {
        await databaseHelper.transaction((txn) async {
          await txn.insert('app_groups', testAppGroup.toMap());
          await txn.insert('timer_sessions', testTimerSession.toMap());
        });

        final group = await databaseHelper.getAppGroupById(testAppGroup.id);
        final session = await databaseHelper.getTimerSession(testTimerSession.groupId);

        expect(group, isNotNull);
        expect(session, isNotNull);
      });
    });

    group('Foreign key constraints', () {
      test('should cascade delete timer sessions when app group is deleted', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateTimerSession(testTimerSession);

        await databaseHelper.deleteAppGroup(testAppGroup.id);

        final session = await databaseHelper.getTimerSession(testTimerSession.groupId);
        expect(session, isNull);
      });

      test('should set group_id to null in usage stats when app group is deleted', () async {
        await databaseHelper.insertAppGroup(testAppGroup);
        await databaseHelper.insertOrUpdateUsageStats(testUsageStats);

        await databaseHelper.deleteAppGroup(testAppGroup.id);

        final stats = await databaseHelper.getUsageStats(testUsageStats.appPackage);
        expect(stats, isNotNull);
        expect(stats!.groupId, isNull);
      });
    });
  });
}