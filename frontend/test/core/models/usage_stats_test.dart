import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/models/models.dart';

void main() {
  group('UsageStats', () {
    late UsageStats testStats;
    late DateTime testLastUsed;

    setUp(() {
      testLastUsed = DateTime(2024, 1, 15, 10, 30);
      testStats = UsageStats(
        appPackage: 'com.instagram.android',
        groupId: 'social-media-group',
        dailyUsage: const Duration(hours: 2, minutes: 30),
        weeklyUsage: const Duration(hours: 15),
        monthlyUsage: const Duration(hours: 60),
        lastUsed: testLastUsed,
      );
    });

    test('should create UsageStats with required fields', () {
      expect(testStats.appPackage, 'com.instagram.android');
      expect(testStats.groupId, 'social-media-group');
      expect(testStats.dailyUsage, const Duration(hours: 2, minutes: 30));
      expect(testStats.weeklyUsage, const Duration(hours: 15));
      expect(testStats.monthlyUsage, const Duration(hours: 60));
      expect(testStats.lastUsed, testLastUsed);
    });

    test('should convert to and from Map correctly', () {
      final map = testStats.toMap();
      final fromMap = UsageStats.fromMap(map);

      expect(fromMap.appPackage, testStats.appPackage);
      expect(fromMap.groupId, testStats.groupId);
      expect(fromMap.dailyUsage, testStats.dailyUsage);
      expect(fromMap.weeklyUsage, testStats.weeklyUsage);
      expect(fromMap.monthlyUsage, testStats.monthlyUsage);
      expect(fromMap.lastUsed, testStats.lastUsed);
    });

    test('should convert to and from JSON correctly', () {
      final json = testStats.toJson();
      final fromJson = UsageStats.fromJson(json);

      expect(fromJson.appPackage, testStats.appPackage);
      expect(fromJson.groupId, testStats.groupId);
      expect(fromJson.dailyUsage, testStats.dailyUsage);
      expect(fromJson.weeklyUsage, testStats.weeklyUsage);
      expect(fromJson.monthlyUsage, testStats.monthlyUsage);
      expect(fromJson.lastUsed, testStats.lastUsed);
    });

    test('should create copy with modified fields', () {
      final copy = testStats.copyWith(
        dailyUsage: const Duration(hours: 3),
        groupId: 'updated-group',
      );

      expect(copy.appPackage, testStats.appPackage);
      expect(copy.groupId, 'updated-group');
      expect(copy.dailyUsage, const Duration(hours: 3));
      expect(copy.weeklyUsage, testStats.weeklyUsage);
      expect(copy.monthlyUsage, testStats.monthlyUsage);
      expect(copy.lastUsed, testStats.lastUsed);
    });

    test('should support equality comparison', () {
      final identical = UsageStats(
        appPackage: 'com.instagram.android',
        groupId: 'social-media-group',
        dailyUsage: const Duration(hours: 2, minutes: 30),
        weeklyUsage: const Duration(hours: 15),
        monthlyUsage: const Duration(hours: 60),
        lastUsed: testLastUsed,
      );

      final different = testStats.copyWith(dailyUsage: const Duration(hours: 1));

      expect(testStats, equals(identical));
      expect(testStats, isNot(equals(different)));
    });

    test('should handle null groupId', () {
      final statsWithoutGroup = UsageStats(
        appPackage: 'com.example.app',
        dailyUsage: const Duration(minutes: 30),
        weeklyUsage: const Duration(hours: 3),
        monthlyUsage: const Duration(hours: 12),
        lastUsed: testLastUsed,
      );

      final map = statsWithoutGroup.toMap();
      final fromMap = UsageStats.fromMap(map);

      expect(fromMap.groupId, isNull);
    });

    test('should handle zero durations', () {
      final zeroStats = UsageStats(
        appPackage: 'com.example.app',
        dailyUsage: Duration.zero,
        weeklyUsage: Duration.zero,
        monthlyUsage: Duration.zero,
        lastUsed: testLastUsed,
      );

      final map = zeroStats.toMap();
      final fromMap = UsageStats.fromMap(map);

      expect(fromMap.dailyUsage, Duration.zero);
      expect(fromMap.weeklyUsage, Duration.zero);
      expect(fromMap.monthlyUsage, Duration.zero);
    });
  });
}