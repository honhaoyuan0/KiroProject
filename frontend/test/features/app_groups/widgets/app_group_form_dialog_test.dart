import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/constants/app_theme.dart';
import 'package:wise_screen/core/models/app_group.dart';
import 'package:wise_screen/features/app_groups/widgets/app_group_form_dialog.dart';

void main() {
  group('AppGroupFormDialog Widget Tests', () {
    late AppGroup testAppGroup;

    setUp(() {
      testAppGroup = AppGroup(
        id: 'test-group-1',
        name: 'Social Media',
        appPackages: ['com.instagram.android', 'com.facebook.katana'],
        timeLimit: const Duration(minutes: 45),
        createdAt: DateTime.now(),
        isActive: true,
      );
    });

    Widget createTestWidget({AppGroup? appGroup}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppGroupFormDialog(appGroup: appGroup),
        ),
      );
    }

    testWidgets('displays create dialog title when creating new group', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Create App Group'), findsOneWidget);
      expect(find.byIcon(Icons.apps), findsOneWidget);
    });

    testWidgets('displays edit dialog title when editing existing group', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(appGroup: testAppGroup));

      expect(find.text('Edit App Group'), findsOneWidget);
    });

    testWidgets('pre-fills form fields when editing existing group', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(appGroup: testAppGroup));
      await tester.pump();

      expect(find.text('Social Media'), findsOneWidget);
      expect(find.text('2 apps selected'), findsOneWidget);
      expect(find.text('45m'), findsOneWidget);
    });

    testWidgets('shows empty form when creating new group', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final nameField = find.byType(TextFormField);
      expect(tester.widget<TextFormField>(nameField).controller?.text, isEmpty);
      expect(find.text('No apps selected'), findsOneWidget);
      expect(find.text('30m'), findsOneWidget); // default time limit
    });

    testWidgets('validates group name field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Try to save without entering name
      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(find.text('Please enter a group name'), findsOneWidget);
    });

    testWidgets('validates minimum group name length', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Enter single character name
      await tester.enterText(find.byType(TextFormField), 'A');
      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(find.text('Group name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('displays time limit preset buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('15m'), findsOneWidget);
      expect(find.text('30m'), findsOneWidget);
      expect(find.text('45m'), findsOneWidget);
      expect(find.text('1h 0m'), findsOneWidget);
      expect(find.text('2h 0m'), findsOneWidget);
      expect(find.text('3h 0m'), findsOneWidget);
    });

    testWidgets('updates time limit when preset button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Initially shows 30m (default)
      expect(find.text('30m'), findsWidgets); // One in display, one in button

      // Tap 1 hour button
      await tester.tap(find.text('1h 0m'));
      await tester.pump();

      // Should now show 1h 0m in the display
      expect(find.text('1h 0m'), findsWidgets);
    });

    testWidgets('shows Add Apps button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Add Apps'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('displays selected apps as chips when editing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(appGroup: testAppGroup));
      await tester.pump();

      expect(find.text('2 apps selected'), findsOneWidget);
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('shows action buttons with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('shows Update button when editing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(appGroup: testAppGroup));
      await tester.pump();

      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('closes dialog when cancel is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AppGroupFormDialog), findsNothing);
    });

    testWidgets('closes dialog when close button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(AppGroupFormDialog), findsNothing);
    });

    testWidgets('shows error when trying to save without apps', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppGroupFormDialog(),
        ),
      ));
      await tester.pump();

      // Enter valid name
      await tester.enterText(find.byType(TextFormField), 'Test Group');
      
      // Try to save without selecting apps
      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(find.text('Please select at least one app'), findsOneWidget);
    });

    testWidgets('displays correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check header has purple background
      final headerContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppGroupFormDialog),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = headerContainer.decoration as BoxDecoration;
      expect(decoration.color, AppTheme.primaryPurple);
    });

    testWidgets('formats duration correctly in display', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(appGroup: testAppGroup));
      await tester.pump();

      // Should show 45m for 45 minute duration
      expect(find.text('45m'), findsOneWidget);
    });

    testWidgets('shows timer icon in time limit section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.timer), findsOneWidget);
    });
  });
}