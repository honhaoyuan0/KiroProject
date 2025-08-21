import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wise_screen/features/analysis/widgets/usage_breakdown_widget.dart';
import 'package:wise_screen/core/services/usage_stats_service.dart';
import 'package:wise_screen/core/constants/app_theme.dart';

void main() {
  group('UsageBreakdownWidget Tests', () {
    late AggregatedUsageStats mockStats;

    setUp(() {
      final now = DateTime.now();
      mockStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 4),
        appUsage: const {
          'com.example.social': Duration(hours: 2),
          'com.example.games': Duration(hours: 1),
          'com.example.productivity': Duration(minutes: 60),
        },
        groupUsage: const {
          'Social Media': Duration(hours: 2, minutes: 30),
          'Entertainment': Duration(hours: 1, minutes: 30),
        },
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: UsageBreakdownWidget(
            stats: mockStats,
            period: TimePeriod.daily,
          ),
        ),
      );
    }

    testWidgets('displays header with title and period', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Usage Breakdown'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('displays toggle buttons for groups and apps', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('App Groups'), findsOneWidget);
      expect(find.text('Individual Apps'), findsOneWidget);
    });

    testWidgets('app groups toggle is selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the container for App Groups button
      final appGroupsButton = find.ancestor(
        of: find.text('App Groups'),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(appGroupsButton);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, equals(AppTheme.primaryPurple));
    });

    testWidgets('switches between groups and apps view', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially shows groups (default)
      // Tap Individual Apps button
      await tester.tap(find.text('Individual Apps'));
      await tester.pumpAndSettle();

      // Individual Apps button should now be selected
      final individualAppsButton = find.ancestor(
        of: find.text('Individual Apps'),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(individualAppsButton);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, equals(AppTheme.primaryPurple));

      // Switch back to groups
      await tester.tap(find.text('App Groups'));
      await tester.pumpAndSettle();

      final appGroupsButton = find.ancestor(
        of: find.text('App Groups'),
        matching: find.byType(Container),
      ).first;

      final groupsContainer = tester.widget<Container>(appGroupsButton);
      final groupsDecoration = groupsContainer.decoration as BoxDecoration;
      
      expect(groupsDecoration.color, equals(AppTheme.primaryPurple));
    });

    testWidgets('displays usage items with correct information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show group usage items
      expect(find.byIcon(Icons.folder), findsWidgets);
      
      // Switch to individual apps
      await tester.tap(find.text('Individual Apps'));
      await tester.pumpAndSettle();

      // Should show app usage items
      expect(find.byIcon(Icons.apps), findsWidgets);
      
      // Should show formatted app names
      expect(find.textContaining('Social'), findsOneWidget);
      expect(find.textContaining('Games'), findsOneWidget);
      expect(find.textContaining('Productivity'), findsOneWidget);
    });

    testWidgets('displays usage duration and percentage correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to individual apps to see specific durations
      await tester.tap(find.text('Individual Apps'));
      await tester.pumpAndSettle();

      // Should show formatted durations
      expect(find.text('2h 0m'), findsOneWidget); // Social app
      expect(find.text('1h 0m'), findsWidgets); // Games and productivity apps
      
      // Should show percentages
      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets('displays progress bars for usage items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show progress indicators
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('handles empty group usage correctly', (WidgetTester tester) async {
      final now = DateTime.now();
      final emptyGroupStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 2),
        appUsage: const {
          'com.example.app1': Duration(hours: 2),
        },
        groupUsage: const {}, // Empty groups
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UsageBreakdownWidget(
              stats: emptyGroupStats,
              period: TimePeriod.daily,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty state for groups
      expect(find.text('No app groups with usage data'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('handles empty app usage correctly', (WidgetTester tester) async {
      final now = DateTime.now();
      final emptyAppStats = AggregatedUsageStats(
        totalUsage: Duration.zero,
        appUsage: const {}, // Empty apps
        groupUsage: const {
          'group1': Duration(hours: 1),
        },
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UsageBreakdownWidget(
              stats: emptyAppStats,
              period: TimePeriod.daily,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to individual apps
      await tester.tap(find.text('Individual Apps'));
      await tester.pumpAndSettle();

      // Should show empty state for apps
      expect(find.text('No individual app usage data'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays correct period labels', (WidgetTester tester) async {
      // Test daily period
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);

      // Test weekly period
      final now = DateTime.now();
      final weeklyStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 10),
        appUsage: const {'com.example.app': Duration(hours: 10)},
        groupUsage: const {'group1': Duration(hours: 10)},
        periodStart: DateTime(now.year, now.month, now.day - 7),
        periodEnd: DateTime(now.year, now.month, now.day),
        period: TimePeriod.weekly,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UsageBreakdownWidget(
              stats: weeklyStats,
              period: TimePeriod.weekly,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('This Week'), findsOneWidget);

      // Test monthly period
      final monthlyStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 50),
        appUsage: const {'com.example.app': Duration(hours: 50)},
        groupUsage: const {'group1': Duration(hours: 50)},
        periodStart: DateTime(now.year, now.month - 1, now.day),
        periodEnd: DateTime(now.year, now.month, now.day),
        period: TimePeriod.monthly,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UsageBreakdownWidget(
              stats: monthlyStats,
              period: TimePeriod.monthly,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('This Month'), findsOneWidget);
    });

    testWidgets('sorts usage items by duration correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to individual apps
      await tester.tap(find.text('Individual Apps'));
      await tester.pumpAndSettle();

      // Find all duration texts
      final durationTexts = find.textContaining('h').evaluate()
          .map((element) => (element.widget as Text).data!)
          .where((text) => text.contains('h') && text.contains('m'))
          .toList();

      // Should be sorted with highest usage first
      expect(durationTexts.first, equals('2h 0m')); // Social app should be first
    });

    testWidgets('displays usage items with proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to individual apps
      await tester.tap(find.text('Individual Apps'));
      await tester.pumpAndSettle();

      // Should have containers with proper styling
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // Should have icons with proper colors
      final icons = find.byIcon(Icons.apps);
      expect(icons, findsWidgets);
    });

    testWidgets('handles zero total usage for percentage calculation', (WidgetTester tester) async {
      final now = DateTime.now();
      final zeroTotalStats = AggregatedUsageStats(
        totalUsage: Duration.zero,
        appUsage: const {
          'com.example.app1': Duration.zero,
        },
        groupUsage: const {},
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UsageBreakdownWidget(
              stats: zeroTotalStats,
              period: TimePeriod.daily,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to individual apps
      await tester.tap(find.text('Individual Apps'));
      await tester.pumpAndSettle();

      // Should handle zero percentage gracefully
      expect(find.text('0.0%'), findsOneWidget);
    });
  });
}