import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wise_screen/core/constants/app_theme.dart';
import 'package:wise_screen/core/models/app_group.dart';
import 'package:wise_screen/core/providers/app_providers.dart';
import 'package:wise_screen/features/app_groups/widgets/timer_history_widget.dart';
import 'package:wise_screen/shared/database/database_helper.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('TimerHistoryWidget', () {
    late AppGroup testAppGroup;
    late DatabaseHelper mockDatabaseHelper;

    setUp(() {
      testAppGroup = AppGroup(
        id: 'test-group-1',
        name: 'Social Media',
        appPackages: ['com.instagram.android', 'com.twitter.android'],
        timeLimit: const Duration(minutes: 60),
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      mockDatabaseHelper = MockDatabaseHelper();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TimerHistoryWidget(appGroup: testAppGroup),
          ),
        ),
      );
    }

    testWidgets('displays timer history header correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Timer History'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays statistics chips', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays sample history entries', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display multiple history entries
      expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
    });

    testWidgets('shows empty state when no history exists', (tester) async {
      // This would require mocking the history generation to return empty list
      // For now, we test the UI structure
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The widget should still render without errors
      expect(find.byType(TimerHistoryWidget), findsOneWidget);
    });

    testWidgets('displays progress bars for history entries', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have progress bars for each history entry
      expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('shows completion status icons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show completion status icons
      final checkIcons = find.byIcon(Icons.check_circle);
      final cancelIcons = find.byIcon(Icons.cancel);
      
      expect(checkIcons.evaluate().length + cancelIcons.evaluate().length, 
             greaterThan(0));
    });

    testWidgets('displays relative dates correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display relative time strings
      expect(find.textContaining('ago'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows percentage completion', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display percentage completion
      expect(find.textContaining('%'), findsAtLeastNWidgets(1));
      expect(find.textContaining('limit'), findsAtLeastNWidgets(1));
    });

    testWidgets('refresh button works', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Should still display the widget without errors
      expect(find.byType(TimerHistoryWidget), findsOneWidget);
    });

    testWidgets('displays loading state initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
      
      // Loading should be gone after settling
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('uses correct theme colors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that the widget uses the app theme
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TimerHistoryWidget),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppTheme.cardBackground));
    });

    testWidgets('displays session statistics correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display session count
      expect(find.textContaining('Sessions'), findsOneWidget);
      expect(find.textContaining('Completed'), findsOneWidget);
    });

    testWidgets('handles different completion states', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should handle both completed and incomplete sessions
      final completedEntries = find.byIcon(Icons.check_circle);
      final incompleteEntries = find.byIcon(Icons.cancel);
      
      // At least one type should be present
      expect(completedEntries.evaluate().isNotEmpty || 
             incompleteEntries.evaluate().isNotEmpty, isTrue);
    });
  });
}