import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:wise_screen/core/services/usage_stats_service.dart';
import 'package:wise_screen/core/models/models.dart';
import 'package:wise_screen/shared/database/database_helper.dart';
import 'usage_stats_service_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  group('UsageStatsService', () {
    late UsageStatsService usageStatsService;
    late MockDatabaseHelper mockDatabaseHelper;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      usageStatsService = UsageStatsService(databaseHelper: mockDatabaseHelper);
    });

    group('getUsageStatistics', () {
      test('should return aggregated daily usage statistics', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 180),
            monthlyUsage: const Duration(minutes: 720),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app2',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 45),
            weeklyUsage: const Duration(minutes: 270),
            monthlyUsage: const Duration(minutes: 1080),
            lastUsed: now,
          ),
        ];

        final mockAppGroups = [
          AppGroup(
            id: 'group1',
            name: 'Social Media',
            appPackages: ['com.example.app1', 'com.example.app2'],
            timeLimit: const Duration(hours: 2),
            createdAt: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => mockAppGroups);

        // Act
        final result = await usageStatsService.getUsageStatistics(TimePeriod.daily);

        // Assert
        expect(result.totalUsage, const Duration(minutes: 75));
        expect(result.appUsage.length, 2);
        expect(result.appUsage['com.example.app1'], const Duration(minutes: 30));
        expect(result.appUsage['com.example.app2'], const Duration(minutes: 45));
        expect(result.groupUsage['group1'], const Duration(minutes: 75));
        expect(result.period, TimePeriod.daily);
      });

      test('should return aggregated weekly usage statistics', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 180),
            monthlyUsage: const Duration(minutes: 720),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getUsageStatistics(TimePeriod.weekly);

        // Assert
        expect(result.totalUsage, const Duration(minutes: 180));
        expect(result.period, TimePeriod.weekly);
      });

      test('should return aggregated monthly usage statistics', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 180),
            monthlyUsage: const Duration(minutes: 720),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getUsageStatistics(TimePeriod.monthly);

        // Assert
        expect(result.totalUsage, const Duration(minutes: 720));
        expect(result.period, TimePeriod.monthly);
      });

      test('should handle empty usage statistics', () async {
        // Arrange
        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getUsageStatistics(TimePeriod.daily);

        // Assert
        expect(result.totalUsage, Duration.zero);
        expect(result.appUsage.isEmpty, true);
        expect(result.groupUsage.isEmpty, true);
      });
    });

    group('getUsageTrends', () {
      test('should calculate usage trends correctly', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60),
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app2',
            groupId: 'group2',
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 150),
            monthlyUsage: const Duration(minutes: 600),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getUsageTrends(TimePeriod.daily);

        // Assert
        expect(result.mostUsedApps.length, 2);
        expect(result.mostUsedApps.first, 'com.example.app1');
        expect(result.totalSessions, 2);
        expect(result.averageSessionLength, const Duration(minutes: 45));
        expect(result.hourlyUsage.length, 24);
      });

      test('should handle zero usage for trends calculation', () async {
        // Arrange
        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getUsageTrends(TimePeriod.daily);

        // Assert
        expect(result.changePercentage, 0.0);
        expect(result.isIncreasing, false);
        expect(result.totalSessions, 1); // Minimum 1 to avoid division by zero
        expect(result.mostUsedApps.isEmpty, true);
        expect(result.mostUsedGroups.isEmpty, true);
      });
    });

    group('getGroupUsageStatistics', () {
      test('should return usage statistics for specific group', () async {
        // Arrange
        final now = DateTime.now();
        final groupId = 'group1';
        final mockGroupStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: groupId,
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 180),
            monthlyUsage: const Duration(minutes: 720),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app2',
            groupId: groupId,
            dailyUsage: const Duration(minutes: 20),
            weeklyUsage: const Duration(minutes: 120),
            monthlyUsage: const Duration(minutes: 480),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getUsageStatsByGroup(groupId))
            .thenAnswer((_) async => mockGroupStats);

        // Act
        final result = await usageStatsService.getGroupUsageStatistics(
          groupId,
          TimePeriod.daily,
        );

        // Assert
        expect(result.totalUsage, const Duration(minutes: 50));
        expect(result.appUsage.length, 2);
        expect(result.groupUsage[groupId], const Duration(minutes: 50));
      });

      test('should handle empty group statistics', () async {
        // Arrange
        final groupId = 'group1';
        when(mockDatabaseHelper.getUsageStatsByGroup(groupId))
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getGroupUsageStatistics(
          groupId,
          TimePeriod.daily,
        );

        // Assert
        expect(result.totalUsage, Duration.zero);
        expect(result.appUsage.isEmpty, true);
        expect(result.groupUsage[groupId], Duration.zero);
      });
    });

    group('updateAppUsage', () {
      test('should create new usage stats for new app', () async {
        // Arrange
        const appPackage = 'com.example.newapp';
        const sessionDuration = Duration(minutes: 15);
        const groupId = 'group1';

        when(mockDatabaseHelper.getUsageStats(appPackage))
            .thenAnswer((_) async => null);
        when(mockDatabaseHelper.insertOrUpdateUsageStats(any))
            .thenAnswer((_) async => 1);

        // Act
        await usageStatsService.updateAppUsage(appPackage, sessionDuration, groupId);

        // Assert
        verify(mockDatabaseHelper.getUsageStats(appPackage)).called(1);
        verify(mockDatabaseHelper.insertOrUpdateUsageStats(any)).called(1);
      });

      test('should update existing usage stats', () async {
        // Arrange
        const appPackage = 'com.example.app';
        const sessionDuration = Duration(minutes: 15);
        const groupId = 'group1';
        final now = DateTime.now();

        final existingStats = UsageStats(
          appPackage: appPackage,
          groupId: groupId,
          dailyUsage: const Duration(minutes: 30),
          weeklyUsage: const Duration(minutes: 180),
          monthlyUsage: const Duration(minutes: 720),
          lastUsed: now.subtract(const Duration(hours: 1)),
        );

        when(mockDatabaseHelper.getUsageStats(appPackage))
            .thenAnswer((_) async => existingStats);
        when(mockDatabaseHelper.insertOrUpdateUsageStats(any))
            .thenAnswer((_) async => 1);

        // Act
        await usageStatsService.updateAppUsage(appPackage, sessionDuration, groupId);

        // Assert
        verify(mockDatabaseHelper.getUsageStats(appPackage)).called(1);
        verify(mockDatabaseHelper.insertOrUpdateUsageStats(any)).called(1);
      });
    });

    group('getTopApps', () {
      test('should return top apps sorted by usage', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60),
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app2',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 150),
            monthlyUsage: const Duration(minutes: 600),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app3',
            groupId: 'group2',
            dailyUsage: const Duration(minutes: 45),
            weeklyUsage: const Duration(minutes: 225),
            monthlyUsage: const Duration(minutes: 900),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getTopApps(TimePeriod.daily, limit: 2);

        // Assert
        expect(result.length, 2);
        expect(result.first.key, 'com.example.app1');
        expect(result.first.value, const Duration(minutes: 60));
        expect(result.last.key, 'com.example.app3');
        expect(result.last.value, const Duration(minutes: 45));
      });
    });

    group('getTopGroups', () {
      test('should return top groups sorted by usage', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60),
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app2',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 150),
            monthlyUsage: const Duration(minutes: 600),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app3',
            groupId: 'group2',
            dailyUsage: const Duration(minutes: 20),
            weeklyUsage: const Duration(minutes: 100),
            monthlyUsage: const Duration(minutes: 400),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getTopGroups(TimePeriod.daily, limit: 2);

        // Assert
        expect(result.length, 2);
        expect(result.first.key, 'group1');
        expect(result.first.value, const Duration(minutes: 90));
        expect(result.last.key, 'group2');
        expect(result.last.value, const Duration(minutes: 20));
      });
    });

    group('resetPeriodStats', () {
      test('should reset daily usage statistics', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60),
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.insertOrUpdateUsageStats(any))
            .thenAnswer((_) async => 1);

        // Act
        await usageStatsService.resetPeriodStats(TimePeriod.daily);

        // Assert
        verify(mockDatabaseHelper.getAllUsageStats()).called(1);
        verify(mockDatabaseHelper.insertOrUpdateUsageStats(any)).called(1);
      });

      test('should reset weekly usage statistics', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60),
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.insertOrUpdateUsageStats(any))
            .thenAnswer((_) async => 1);

        // Act
        await usageStatsService.resetPeriodStats(TimePeriod.weekly);

        // Assert
        verify(mockDatabaseHelper.getAllUsageStats()).called(1);
        verify(mockDatabaseHelper.insertOrUpdateUsageStats(any)).called(1);
      });

      test('should reset monthly usage statistics', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60),
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.insertOrUpdateUsageStats(any))
            .thenAnswer((_) async => 1);

        // Act
        await usageStatsService.resetPeriodStats(TimePeriod.monthly);

        // Assert
        verify(mockDatabaseHelper.getAllUsageStats()).called(1);
        verify(mockDatabaseHelper.insertOrUpdateUsageStats(any)).called(1);
      });
    });

    group('getUsagePercentages', () {
      test('should calculate usage percentages correctly', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60), // 60% of total
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app2',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 40), // 40% of total
            weeklyUsage: const Duration(minutes: 200),
            monthlyUsage: const Duration(minutes: 800),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getUsagePercentages(TimePeriod.daily);

        // Assert
        expect(result.length, 2);
        expect(result['com.example.app1'], 60.0);
        expect(result['com.example.app2'], 40.0);
      });

      test('should handle zero total usage', () async {
        // Arrange
        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getUsagePercentages(TimePeriod.daily);

        // Assert
        expect(result.isEmpty, true);
      });
    });

    group('getMultipleGroupsUsageStatistics', () {
      test('should return usage statistics for multiple groups', () async {
        // Arrange
        final now = DateTime.now();
        final groupIds = ['group1', 'group2'];
        
        final mockGroup1Stats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 180),
            monthlyUsage: const Duration(minutes: 720),
            lastUsed: now,
          ),
        ];

        final mockGroup2Stats = [
          UsageStats(
            appPackage: 'com.example.app2',
            groupId: 'group2',
            dailyUsage: const Duration(minutes: 45),
            weeklyUsage: const Duration(minutes: 270),
            monthlyUsage: const Duration(minutes: 1080),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getUsageStatsByGroup('group1'))
            .thenAnswer((_) async => mockGroup1Stats);
        when(mockDatabaseHelper.getUsageStatsByGroup('group2'))
            .thenAnswer((_) async => mockGroup2Stats);

        // Act
        final result = await usageStatsService.getMultipleGroupsUsageStatistics(
          groupIds,
          TimePeriod.daily,
        );

        // Assert
        expect(result.length, 2);
        expect(result['group1']?.totalUsage, const Duration(minutes: 30));
        expect(result['group2']?.totalUsage, const Duration(minutes: 45));
      });
    });

    group('getSummaryStatistics', () {
      test('should return comprehensive summary statistics', () async {
        // Arrange
        final now = DateTime.now();
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60),
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: now,
          ),
          UsageStats(
            appPackage: 'com.example.app2',
            groupId: 'group2',
            dailyUsage: const Duration(minutes: 30),
            weeklyUsage: const Duration(minutes: 150),
            monthlyUsage: const Duration(minutes: 600),
            lastUsed: now,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.getAllAppGroups())
            .thenAnswer((_) async => []);

        // Act
        final result = await usageStatsService.getSummaryStatistics(TimePeriod.daily);

        // Assert
        expect(result['totalUsage'], const Duration(minutes: 90));
        expect(result['totalApps'], 2);
        expect(result['totalGroups'], 2);
        expect(result['averageSessionLength'], const Duration(minutes: 45));
        expect(result['changePercentage'], 0.0);
        expect(result['isIncreasing'], false);
        expect(result['mostUsedApp'], 'com.example.app1');
      });
    });

    group('performPeriodicReset', () {
      test('should reset usage statistics when periods change', () async {
        // Arrange
        final oldDate = DateTime.now().subtract(const Duration(days: 2));
        final mockUsageStats = [
          UsageStats(
            appPackage: 'com.example.app1',
            groupId: 'group1',
            dailyUsage: const Duration(minutes: 60),
            weeklyUsage: const Duration(minutes: 300),
            monthlyUsage: const Duration(minutes: 1200),
            lastUsed: oldDate,
          ),
        ];

        when(mockDatabaseHelper.getAllUsageStats())
            .thenAnswer((_) async => mockUsageStats);
        when(mockDatabaseHelper.insertOrUpdateUsageStats(any))
            .thenAnswer((_) async => 1);

        // Act
        await usageStatsService.performPeriodicReset();

        // Assert
        verify(mockDatabaseHelper.getAllUsageStats()).called(1);
        verify(mockDatabaseHelper.insertOrUpdateUsageStats(any)).called(1);
      });
    });
  });
}