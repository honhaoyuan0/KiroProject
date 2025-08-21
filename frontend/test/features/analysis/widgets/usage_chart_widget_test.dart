import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:wise_screen/features/analysis/widgets/usage_chart_widget.dart';
import 'package:wise_screen/core/services/usage_stats_service.dart';
import 'package:wise_screen/core/constants/app_theme.dart';

void main() {
  group('UsageChartWidget Tests', () {
    late AggregatedUsageStats mockStats;
    late UsageTrends mockTrends;

    setUp(() {
      final now = DateTime.now();
      mockStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 3),
        appUsage: const {
          'com.example.app1': Duration(hours: 1, minutes: 30),
          'com.example.app2': Duration(minutes: 45),
          'com.example.app3': Duration(minutes: 45),
        },
        groupUsage: const {
          'group1': Duration(hours: 2),
          'group2': Duration(hours: 1),
        },
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );

      mockTrends = const UsageTrends(
        changePercentage: 10.0,
        isIncreasing: true,
        averageSessionLength: Duration(minutes: 30),
        totalSessions: 6,
        mostUsedApps: ['com.example.app1', 'com.example.app2'],
        mostUsedGroups: ['group1'],
        hourlyUsage: {
          9: Duration(minutes: 30),
          14: Duration(minutes: 60),
          19: Duration(minutes: 90),
        },
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: UsageChartWidget(
            stats: mockStats,
            trends: mockTrends,
            period: TimePeriod.daily,
          ),
        ),
      );
    }

    testWidgets('displays chart type selector buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show all three chart type buttons
      expect(find.text('Pie'), findsOneWidget);
      expect(find.text('Bar'), findsOneWidget);
      expect(find.text('Trend'), findsOneWidget);
      
      expect(find.byIcon(Icons.pie_chart), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('pie chart is selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pie chart button should be selected (has purple background)
      final pieButton = tester.widget<Container>(
        find.ancestor(
          of: find.text('Pie'),
          matching: find.byType(Container),
        ).first,
      );
      
      expect((pieButton.decoration as BoxDecoration).color, 
             equals(AppTheme.primaryPurple));
    });

    testWidgets('switches between chart types correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially shows pie chart
      expect(find.byType(PieChart), findsOneWidget);

      // Tap bar chart button
      await tester.tap(find.text('Bar'));
      await tester.pumpAndSettle();
      expect(find.byType(BarChart), findsOneWidget);

      // Tap line chart button
      await tester.tap(find.text('Trend'));
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);

      // Tap pie chart button again
      await tester.tap(find.text('Pie'));
      await tester.pumpAndSettle();
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('pie chart displays legend correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show pie chart with legend
      expect(find.byType(PieChart), findsOneWidget);
      
      // Legend should show app names (simplified)
      expect(find.textContaining('App1'), findsOneWidget);
      expect(find.textContaining('App2'), findsOneWidget);
      expect(find.textContaining('App3'), findsOneWidget);
    });

    testWidgets('displays no data widget when stats are empty', (WidgetTester tester) async {
      final now = DateTime.now();
      final emptyStats = AggregatedUsageStats(
        totalUsage: Duration.zero,
        appUsage: const {},
        groupUsage: const {},
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UsageChartWidget(
              stats: emptyStats,
              trends: mockTrends,
              period: TimePeriod.daily,
            ),
          ),
        ),
      );

      // Should show no data message
      expect(find.text('No usage data available'), findsOneWidget);
      expect(find.text('Start using apps to see your usage patterns'), findsOneWidget);
      // Check for the large icon in the no data widget (size 64)
      expect(find.byWidgetPredicate((widget) => 
        widget is Icon && 
        widget.icon == Icons.bar_chart && 
        widget.size == 64), findsOneWidget);
    });

    testWidgets('bar chart displays correctly with data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Switch to bar chart
      await tester.tap(find.text('Bar'));
      await tester.pumpAndSettle();

      // Should show bar chart
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('line chart displays hourly usage pattern', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Switch to line chart
      await tester.tap(find.text('Trend'));
      await tester.pumpAndSettle();

      // Should show line chart
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('handles zero total usage correctly', (WidgetTester tester) async {
      final now = DateTime.now();
      final zeroStats = AggregatedUsageStats(
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
            body: UsageChartWidget(
              stats: zeroStats,
              trends: mockTrends,
              period: TimePeriod.daily,
            ),
          ),
        ),
      );

      // Should show no data widget
      expect(find.text('No usage data available'), findsOneWidget);
    });

    testWidgets('chart type buttons have correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that unselected buttons have transparent background
      await tester.tap(find.text('Bar'));
      await tester.pumpAndSettle();

      // Pie button should now be unselected
      final pieButtonContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Pie'),
          matching: find.byType(Container),
        ).first,
      );
      
      expect((pieButtonContainer.decoration as BoxDecoration).color, 
             equals(Colors.transparent));

      // Bar button should be selected
      final barButtonContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Bar'),
          matching: find.byType(Container),
        ).first,
      );
      
      expect((barButtonContainer.decoration as BoxDecoration).color, 
             equals(AppTheme.primaryPurple));
    });

    testWidgets('displays correct chart height', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the SizedBox that contains the chart
      final chartContainer = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(PieChart),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(chartContainer.height, equals(300));
    });

    testWidgets('handles large number of apps correctly', (WidgetTester tester) async {
      // Create stats with many apps
      final now = DateTime.now();
      final manyAppsStats = AggregatedUsageStats(
        totalUsage: const Duration(hours: 10),
        appUsage: Map.fromEntries(
          List.generate(15, (index) => MapEntry(
            'com.example.app$index',
            const Duration(minutes: 40),
          )),
        ),
        groupUsage: const {},
        periodStart: DateTime(now.year, now.month, now.day),
        periodEnd: DateTime(now.year, now.month, now.day + 1),
        period: TimePeriod.daily,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UsageChartWidget(
              stats: manyAppsStats,
              trends: mockTrends,
              period: TimePeriod.daily,
            ),
          ),
        ),
      );

      // Should still display pie chart (limited to top 8 apps)
      expect(find.byType(PieChart), findsOneWidget);
    });
  });
}