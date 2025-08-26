import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wise_screen/core/constants/app_theme.dart';
import 'package:wise_screen/core/models/app_group.dart';
import 'package:wise_screen/core/models/timer_session.dart';
import 'package:wise_screen/core/providers/app_providers.dart';
import 'package:wise_screen/features/app_groups/widgets/timer_control_widget.dart';
import 'package:wise_screen/shared/database/database_helper.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('TimerControlWidget', () {
    late AppGroup testAppGroup;
    late DatabaseHelper mockDatabaseHelper;

    setUp(() {
      testAppGroup = AppGroup(
        id: 'test-group-1',
        name: 'Social Media',
        appPackages: ['com.instagram.android', 'com.twitter.android'],
        timeLimit: const Duration(minutes: 30),
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      mockDatabaseHelper = MockDatabaseHelper();
    });

    Widget createTestWidget({
      TimerSession? timerSession,
      VoidCallback? onTimerUpdated,
    }) {
      return ProviderScope(
        overrides: [
          databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TimerControlWidget(
              appGroup: testAppGroup,
              timerSession: timerSession,
              onTimerUpdated: onTimerUpdated,
            ),
          ),
        ),
      );
    }

    testWidgets('displays inactive timer state when no session exists', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Inactive'), findsOneWidget);
      expect(find.text('30m 0s'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);
      expect(find.byIcon(Icons.timer_off), findsOneWidget);
    });

    testWidgets('displays active timer state when session is active', (tester) async {
      final activeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 10)),
        elapsedTime: const Duration(minutes: 10),
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(timerSession: activeSession));

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.text('Quick Add Time:'), findsOneWidget);
    });

    testWidgets('displays time up state when timer exceeds limit', (tester) async {
      final overtimeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 35)),
        elapsedTime: const Duration(minutes: 35),
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(timerSession: overtimeSession));

      expect(find.text('Time Up!'), findsOneWidget);
      expect(find.text('0s'), findsOneWidget);
      expect(find.byIcon(Icons.timer_off), findsOneWidget);
    });

    testWidgets('shows progress bar for active timer', (tester) async {
      final activeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 15)),
        elapsedTime: const Duration(minutes: 15),
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(timerSession: activeSession));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, equals(0.5)); // 15 minutes of 30 minutes
    });

    testWidgets('displays quick time buttons when timer is active', (tester) async {
      final activeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now(),
        elapsedTime: Duration.zero,
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(timerSession: activeSession));

      expect(find.text('+5m'), findsOneWidget);
      expect(find.text('+10m'), findsOneWidget);
      expect(find.text('+15m'), findsOneWidget);
      expect(find.text('+30m'), findsOneWidget);
    });

    testWidgets('hides quick time buttons when timer is inactive', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('+5m'), findsNothing);
      expect(find.text('+10m'), findsNothing);
      expect(find.text('+15m'), findsNothing);
      expect(find.text('+30m'), findsNothing);
    });

    testWidgets('start button starts timer', (tester) async {
      bool timerUpdated = false;
      
      await tester.pumpWidget(createTestWidget(
        onTimerUpdated: () => timerUpdated = true,
      ));

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(timerUpdated, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Timer started for "Social Media"'), findsOneWidget);
    });

    testWidgets('pause button pauses active timer', (tester) async {
      final activeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now(),
        elapsedTime: Duration.zero,
        isActive: true,
      );

      bool timerUpdated = false;
      
      await tester.pumpWidget(createTestWidget(
        timerSession: activeSession,
        onTimerUpdated: () => timerUpdated = true,
      ));

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(timerUpdated, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Timer paused for "Social Media"'), findsOneWidget);
    });

    testWidgets('stop button stops timer', (tester) async {
      final activeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now(),
        elapsedTime: const Duration(minutes: 10),
        isActive: true,
      );

      bool timerUpdated = false;
      
      await tester.pumpWidget(createTestWidget(
        timerSession: activeSession,
        onTimerUpdated: () => timerUpdated = true,
      ));

      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();

      expect(timerUpdated, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Timer stopped for "Social Media"'), findsOneWidget);
    });

    testWidgets('quick add time buttons work correctly', (tester) async {
      final activeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now(),
        elapsedTime: Duration.zero,
        isActive: true,
      );

      bool timerUpdated = false;
      
      await tester.pumpWidget(createTestWidget(
        timerSession: activeSession,
        onTimerUpdated: () => timerUpdated = true,
      ));

      await tester.tap(find.text('+5m'));
      await tester.pumpAndSettle();

      expect(timerUpdated, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Added 5m to "Social Media"'), findsOneWidget);
    });

    testWidgets('displays usage statistics correctly', (tester) async {
      final activeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 20)),
        elapsedTime: const Duration(minutes: 20),
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(timerSession: activeSession));

      expect(find.text('Limit: 30m'), findsOneWidget);
      expect(find.text('Used: 20m'), findsOneWidget);
    });

    testWidgets('shows warning color when time is running low', (tester) async {
      final lowTimeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 27)),
        elapsedTime: const Duration(minutes: 27),
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(timerSession: lowTimeSession));

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.valueColor?.value, equals(AppTheme.warningColor));
    });

    testWidgets('shows error color when time is up', (tester) async {
      final overtimeSession = TimerSession(
        groupId: testAppGroup.id,
        startTime: DateTime.now().subtract(const Duration(minutes: 35)),
        elapsedTime: const Duration(minutes: 35),
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(timerSession: overtimeSession));

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.valueColor?.value, equals(AppTheme.errorColor));
    });

    testWidgets('disables buttons when loading', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap start button to trigger loading state
      await tester.tap(find.text('Start'));
      await tester.pump(); // Don't settle to catch loading state

      // Check that buttons show loading indicators
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });
  });
}