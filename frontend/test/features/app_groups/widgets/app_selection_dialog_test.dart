import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/constants/app_theme.dart';
import 'package:wise_screen/features/app_groups/widgets/app_selection_dialog.dart';

void main() {
  group('AppSelectionDialog Widget Tests', () {
    Widget createTestWidget({List<String> selectedApps = const []}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppSelectionDialog(selectedApps: selectedApps),
        ),
      );
    }

    testWidgets('displays dialog title and selected count', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(selectedApps: ['com.instagram.android']));
      await tester.pump();

      expect(find.text('Select Apps'), findsOneWidget);
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byIcon(Icons.apps), findsOneWidget);
    });

    testWidgets('shows zero selected when no apps pre-selected', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('0 selected'), findsOneWidget);
    });

    testWidgets('displays search bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search apps...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading installed apps...'), findsOneWidget);
    });

    testWidgets('displays mock apps after loading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Facebook'), findsOneWidget);
      expect(find.text('YouTube'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('filters apps based on search query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      // Enter search query
      await tester.enterText(find.byType(TextField), 'insta');
      await tester.pump();

      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Facebook'), findsNothing);
    });

    testWidgets('shows no results message when search yields no matches', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      // Enter search query that matches nothing
      await tester.enterText(find.byType(TextField), 'nonexistentapp');
      await tester.pump();

      expect(find.text('No apps found'), findsOneWidget);
      expect(find.text('Try adjusting your search terms'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('pre-selects apps that were passed in', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        selectedApps: ['com.instagram.android', 'com.facebook.katana'],
      ));
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      // Find checkboxes for Instagram and Facebook
      final instagramTile = find.ancestor(
        of: find.text('Instagram'),
        matching: find.byType(CheckboxListTile),
      );
      final facebookTile = find.ancestor(
        of: find.text('Facebook'),
        matching: find.byType(CheckboxListTile),
      );

      expect(tester.widget<CheckboxListTile>(instagramTile).value, isTrue);
      expect(tester.widget<CheckboxListTile>(facebookTile).value, isTrue);
    });

    testWidgets('toggles app selection when checkbox is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      // Find Instagram checkbox and tap it
      final instagramTile = find.ancestor(
        of: find.text('Instagram'),
        matching: find.byType(CheckboxListTile),
      );

      expect(tester.widget<CheckboxListTile>(instagramTile).value, isFalse);

      await tester.tap(instagramTile);
      await tester.pump();

      expect(tester.widget<CheckboxListTile>(instagramTile).value, isTrue);
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      expect(find.text('Clear All'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Select (0)'), findsOneWidget);
    });

    testWidgets('updates select button count when apps are selected', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      // Select Instagram
      final instagramTile = find.ancestor(
        of: find.text('Instagram'),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(instagramTile);
      await tester.pump();

      expect(find.text('Select (1)'), findsOneWidget);
    });

    testWidgets('clears all selections when Clear All is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        selectedApps: ['com.instagram.android', 'com.facebook.katana'],
      ));
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      expect(find.text('2 selected'), findsOneWidget);

      await tester.tap(find.text('Clear All'));
      await tester.pump();

      expect(find.text('0 selected'), findsOneWidget);
      expect(find.text('Select (0)'), findsOneWidget);
    });

    testWidgets('closes dialog when Cancel is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AppSelectionDialog), findsNothing);
    });

    testWidgets('closes dialog when close button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(AppSelectionDialog), findsNothing);
    });

    testWidgets('displays app icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      // Check that app tiles have leading icons
      final appTiles = find.byType(CheckboxListTile);
      expect(appTiles, findsWidgets);

      // Each tile should have a leading container with an icon
      final leadingContainers = find.descendant(
        of: appTiles.first,
        matching: find.byType(Container),
      );
      expect(leadingContainers, findsWidgets);
    });

    testWidgets('shows package names as subtitles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      expect(find.text('com.instagram.android'), findsOneWidget);
      expect(find.text('com.facebook.katana'), findsOneWidget);
    });

    testWidgets('applies correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(); // After loading completes

      // Check header has purple background
      final headerContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppSelectionDialog),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = headerContainer.decoration as BoxDecoration;
      expect(decoration.color, AppTheme.primaryPurple);
    });
  });
}