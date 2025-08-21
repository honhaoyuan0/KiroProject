import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:wise_screen/features/analysis/screen_insights_page.dart';
import 'package:wise_screen/core/services/usage_stats_service.dart';
import 'package:wise_screen/core/constants/app_theme.dart';

import 'screen_insights_page_test.mocks.dart';

@GenerateMocks([UsageStatsService])
void main() {
  group('ScreenInsightsPage Widget Tests', () {
    late MockUsageStatsService mockUsageStatsService;
    late AggregatedUsageStats mockDailyStats;
    late AggregatedUsageStats mockWeeklyStats;
    late AggregatedUsageStats mockMonthlyStats;
    late UsageTrends mockDailyTrends;
    late UsageTrends mockWeeklyTrends;
    late UsageTrends mockMonthlyTrends;

    setUp(() {
      mockUsageStatsService = MockUsageStatsService();
      
      // Create mock data
      final now = DateTime.now();
      mockDailyStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 2, minutes: 30),
        appUsage: const {
          'com.example.app1': Duration(hours: 1, minutes: 30),
          'com.example.app2': Duration(minutes: 45),
          'com.example.app3': Duration(minutes: 15),
        },
        groupUsage: const {
          'group1': Duration(hours: 1, minutes: 30),
          'group2': Duration(minutes: 60),
        },
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );

      mockWeeklyStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 15),
        appUsage: const {
          'com.example.app1': Duration(hours: 8),
          'com.example.app2': Duration(hours: 4),
          'com.example.app3': Duration(hours: 3),
        },
        groupUsage: const {
          'group1': Duration(hours: 8),
          'group2': Duration(hours: 7),
        },
        periodStart: DateTime(now.year, now.month, now.day - 7),
        periodEnd: DateTime(now.year, now.month, now.day),
        period: TimePeriod.weekly,
      );

      mockMonthlyStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 60),
        appUsage: const {
          'com.example.app1': Duration(hours: 30),
          'com.example.app2': Duration(hours: 20),
          'com.example.app3': Duration(hours: 10),
        },
        groupUsage: const {
          'group1': Duration(hours: 30),
          'group2': Duration(hours: 30),
        },
        periodStart: DateTime(now.year, now.month - 1, now.day),
        periodEnd: DateTime(now.year, now.month, now.day),
        period: TimePeriod.monthly,
      );

      mockDailyTrends = const UsageTrends(
        changePercentage: 15.5,
        isIncreasing: true,
        averageSessionLength: Duration(minutes: 25),
        totalSessions: 6,
        mostUsedApps: ['com.example.app1', 'com.example.app2'],
        mostUsedGroups: ['group1', 'group2'],
        hourlyUsage: {
          9: Duration(minutes: 30),
          14: Duration(minutes: 45),
          19: Duration(minutes: 75),
        },
      );

      mockWeeklyTrends = const UsageTrends(
        changePercentage: -8.2,
        isIncreasing: false,
        averageSessionLength: Duration(minutes: 30),
        totalSessions: 30,
        mostUsedApps: ['com.example.app1', 'com.example.app2'],
        mostUsedGroups: ['group1', 'group2'],
        hourlyUsage: {},
      );

      mockMonthlyTrends = const UsageTrends(
        changePercentage: 5.0,
        isIncreasing: true,
        averageSessionLength: Duration(minutes: 35),
        totalSessions: 120,
        mostUsedApps: ['com.example.app1', 'com.example.app2'],
        mostUsedGroups: ['group1', 'group2'],
        hourlyUsage: {},
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Provider<UsageStatsService>.value(
          value: mockUsageStatsService,
          child: const ScreenInsightsPage(),
        ),
      );
    }

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      // Setup mocks to delay response
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => Future.delayed(
                const Duration(seconds: 1),
                () => mockDailyStats,
              ));
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => Future.delayed(
                const Duration(seconds: 1),
                () => mockDailyTrends,
              ));

      await tester.pumpWidget(createTestWidget());

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading usage insights...'), findsOneWidget);
    });

    testWidgets('displays tab navigation with correct tabs', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(TimePeriod.daily))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageStatistics(TimePeriod.weekly))
          .thenAnswer((_) async => mockWeeklyStats);
      when(mockUsageStatsService.getUsageStatistics(TimePeriod.monthly))
          .thenAnswer((_) async => mockMonthlyStats);
      when(mockUsageStatsService.getUsageTrends(TimePeriod.daily))
          .thenAnswer((_) async => mockDailyTrends);
      when(mockUsageStatsService.getUsageTrends(TimePeriod.weekly))
          .thenAnswer((_) async => mockWeeklyTrends);
      when(mockUsageStatsService.getUsageTrends(TimePeriod.monthly))
          .thenAnswer((_) async => mockMonthlyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show tab bar with three tabs
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('displays app bar with title and refresh button', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => mockDailyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show app bar with title
      expect(find.text('Screen Insights'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays summary statistics widget', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => mockDailyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show summary section
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Total Usage'), findsOneWidget);
      expect(find.text('Apps Used'), findsOneWidget);
      expect(find.text('Avg Session'), findsOneWidget);
      expect(find.text('Active Groups'), findsOneWidget);
    });

    testWidgets('displays AI insights card', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => mockDailyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show AI insights section
      expect(find.text('AI Insights'), findsOneWidget);
      expect(find.text('Personalized recommendations'), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('displays usage chart widget', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => mockDailyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show usage overview section
      expect(find.text('Usage Overview'), findsOneWidget);
      expect(find.text('Pie'), findsOneWidget);
      expect(find.text('Bar'), findsOneWidget);
      expect(find.text('Trend'), findsOneWidget);
    });

    testWidgets('displays usage breakdown widget', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => mockDailyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show usage breakdown section
      expect(find.text('Usage Breakdown'), findsOneWidget);
      expect(find.text('App Groups'), findsOneWidget);
      expect(find.text('Individual Apps'), findsOneWidget);
    });

    testWidgets('switches between tabs correctly', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(TimePeriod.daily))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageStatistics(TimePeriod.weekly))
          .thenAnswer((_) async => mockWeeklyStats);
      when(mockUsageStatsService.getUsageStatistics(TimePeriod.monthly))
          .thenAnswer((_) async => mockMonthlyStats);
      when(mockUsageStatsService.getUsageTrends(TimePeriod.daily))
          .thenAnswer((_) async => mockDailyTrends);
      when(mockUsageStatsService.getUsageTrends(TimePeriod.weekly))
          .thenAnswer((_) async => mockWeeklyTrends);
      when(mockUsageStatsService.getUsageTrends(TimePeriod.monthly))
          .thenAnswer((_) async => mockMonthlyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially on Daily tab
      expect(find.text('Today'), findsOneWidget);

      // Tap Weekly tab
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(find.text('This week'), findsOneWidget);

      // Tap Monthly tab
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      expect(find.text('This month'), findsOneWidget);
    });

    testWidgets('handles error state correctly', (WidgetTester tester) async {
      // Setup mocks to throw error
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenThrow(Exception('Network error'));
      when(mockUsageStatsService.getUsageTrends(any))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Failed to load usage data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('refresh functionality works', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => mockDailyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Verify service methods were called again
      verify(mockUsageStatsService.getUsageStatistics(any)).called(greaterThan(3));
      verify(mockUsageStatsService.getUsageTrends(any)).called(greaterThan(3));
    });

    testWidgets('pull to refresh works', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => mockDailyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Perform pull to refresh
      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify service methods were called again
      verify(mockUsageStatsService.getUsageStatistics(any)).called(greaterThan(3));
      verify(mockUsageStatsService.getUsageTrends(any)).called(greaterThan(3));
    });

    testWidgets('displays no data message when stats are empty', (WidgetTester tester) async {
      // Setup mocks with empty data
      final now = DateTime.now();
      final emptyStats = AggregatedUsageStats(
        totalUsage: Duration.zero,
        appUsage: const {},
        groupUsage: const {},
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );

      const emptyTrends = UsageTrends(
        changePercentage: 0,
        isIncreasing: false,
        averageSessionLength: Duration.zero,
        totalSessions: 0,
        mostUsedApps: [],
        mostUsedGroups: [],
        hourlyUsage: {},
      );

      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => emptyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => emptyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show appropriate empty states
      expect(find.text('0'), findsWidgets); // Zero values in summary
    });

    testWidgets('applies consistent theming', (WidgetTester tester) async {
      // Setup successful mocks
      when(mockUsageStatsService.getUsageStatistics(any))
          .thenAnswer((_) async => mockDailyStats);
      when(mockUsageStatsService.getUsageTrends(any))
          .thenAnswer((_) async => mockDailyTrends);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find cards and verify they exist (theming is applied through theme)
      expect(find.byType(Card), findsWidgets);
      
      // Verify purple theme elements are present
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.labelColor, equals(AppTheme.primaryPurple));
    });
  });
}