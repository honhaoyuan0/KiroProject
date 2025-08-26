import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/constants/app_theme.dart';
import 'package:wise_screen/core/models/app_group.dart';
import 'package:wise_screen/core/models/timer_session.dart';
import 'package:wise_screen/features/app_groups/widgets/app_group_card.dart';

void main() {
  group('AppGroupCard Widget Tests', () {
    late AppGroup testAppGroup;
    late TimerSession testTimerSession;

    setUp(() {
      testAppGroup = AppGroup(
        id: 'test-group-1',
        name: 'Social Media',
        appPackages: ['com.instagram.android', 'com.facebook.katana', 'com.twitter.android'],
        timeLimit: const Duration(minutes: 30),
        createdAt: DateTime.now(),
        isActive: true,
      );

      testTimerSession = TimerSession(
        groupId: 'test-group-1',
        startTime: DateTime.now().subtract(const Duration(minutes: 10)),
        elapsedTime: const Duration(minutes: 10),
        isActive: true,
      );
    });

    Widget createTestWidget({
      AppGroup? appGroup,
      TimerSession? timerSession,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
      VoidCallback? onTimerAction,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppGroupCard(
            appGroup: appGroup ?? testAppGroup,
            timerSession: timerSession,
            onEdit: onEdit ?? () {},
            onDelete: onDelete ?? () {},
            onTimerAction: onTimerAction ?? () {},
          ),
        ),
      );
    }

    testWidgets('displays app group name and basic info', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Social Media'), findsOneWidget);
      expect(find.text('3 apps • 30m limit'), findsOneWidget);
    });

    testWidgets('displays selected apps in chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Apps in this group:'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget); // from com.instagram.android
      expect(find.text('Katana'), findsOneWidget); // from com.facebook.katana
      expect(find.text('Android'), findsWidgets); // appears multiple times
    });

    testWidgets('shows empty state when no apps selected', (WidgetTester tester) async {
      final emptyGroup = testAppGroup.copyWith(appPackages: []);
      await tester.pumpWidget(createTestWidget(appGroup: emptyGroup));

      expect(find.text('No apps selected'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays active timer status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(timerSession: testTimerSession));

      expect(find.text('Timer Active'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.text('20m'), findsOneWidget); // 30m limit - 10m elapsed = 20m remaining
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays inactive timer status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(timerSession: null));

      expect(find.text('Timer Inactive'), findsOneWidget);
      expect(find.byIcon(Icons.timer_off), findsOneWidget);
      expect(find.text('30m'), findsOneWidget); // full time limit shown
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows correct action buttons for inactive timer', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(timerSession: null));

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows correct action buttons for active timer', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(timerSession: testTimerSession));

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('calls onEdit when edit button is tapped', (WidgetTester tester) async {
      bool editCalled = false;
      await tester.pumpWidget(createTestWidget(
        onEdit: () => editCalled = true,
      ));

      await tester.tap(find.text('Edit'));
      await tester.pump();

      expect(editCalled, isTrue);
    });

    testWidgets('calls onTimerAction when timer button is tapped', (WidgetTester tester) async {
      bool timerActionCalled = false;
      await tester.pumpWidget(createTestWidget(
        onTimerAction: () => timerActionCalled = true,
      ));

      await tester.tap(find.text('Start'));
      await tester.pump();

      expect(timerActionCalled, isTrue);
    });

    testWidgets('shows popup menu with edit and delete options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsWidgets); // One in button, one in menu
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsWidgets);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('calls onDelete when delete menu item is tapped', (WidgetTester tester) async {
      bool deleteCalled = false;
      await tester.pumpWidget(createTestWidget(
        onDelete: () => deleteCalled = true,
      ));

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deleteCalled, isTrue);
    });

    testWidgets('shows warning color for low remaining time', (WidgetTester tester) async {
      final lowTimeSession = TimerSession(
        groupId: 'test-group-1',
        startTime: DateTime.now().subtract(const Duration(minutes: 27)),
        elapsedTime: const Duration(minutes: 27),
        isActive: true,
      );

      await tester.pumpWidget(createTestWidget(timerSession: lowTimeSession));

      expect(find.text('3m'), findsOneWidget); // 30m - 27m = 3m remaining
      
      // Find the LinearProgressIndicator and check its color
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.valueColor?.value, AppTheme.errorColor);
    });

    testWidgets('truncates app list when more than 5 apps', (WidgetTester tester) async {
      final manyAppsGroup = testAppGroup.copyWith(
        appPackages: [
          'com.app1', 'com.app2', 'com.app3', 'com.app4', 'com.app5', 'com.app6', 'com.app7'
        ],
      );

      await tester.pumpWidget(createTestWidget(appGroup: manyAppsGroup));

      expect(find.text('+2 more'), findsOneWidget);
    });
  });
}