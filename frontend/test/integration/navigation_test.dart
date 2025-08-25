import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wise_screen/core/constants/app_theme.dart';
import 'package:wise_screen/core/providers/app_providers.dart';
import 'package:wise_screen/core/routing/app_router.dart';
import 'package:wise_screen/features/navigation/main_navigation.dart';
import 'package:wise_screen/features/splash/splash_screen.dart';
import 'package:wise_screen/shared/database/database_helper.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('should show splash screen initially', (WidgetTester tester) async {
      // Create a mock database helper for testing
      final mockDatabaseHelper = DatabaseHelper();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      );

      // Verify splash screen is shown
      expect(find.text('WiseScreen'), findsOneWidget);
      expect(find.text('Smart Screen Time Management'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show main navigation directly', (WidgetTester tester) async {
      // Create a mock database helper for testing
      final mockDatabaseHelper = DatabaseHelper();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
          ],
          child: const MaterialApp(
            home: MainNavigation(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pump();

      // Verify main navigation is shown
      expect(find.byType(MainNavigation), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should switch between navigation tabs', (WidgetTester tester) async {
      // Create a mock database helper for testing
      final mockDatabaseHelper = DatabaseHelper();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
          ],
          child: const MaterialApp(
            home: MainNavigation(),
          ),
        ),
      );

      await tester.pump();

      // Initially should show App Groups page (check for app bar title)
      expect(find.text('App Groups').first, findsOneWidget);

      // Tap on Insights tab in bottom navigation
      final insightsTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Insights'),
      );
      await tester.tap(insightsTab);
      await tester.pump();

      // Should show Screen Insights page
      expect(find.text('Screen Insights'), findsOneWidget);

      // Tap back on App Groups tab in bottom navigation
      final appGroupsTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('App Groups'),
      );
      await tester.tap(appGroupsTab);
      await tester.pump();

      // Should show App Groups page again (check for app bar title)
      expect(find.text('App Groups').first, findsOneWidget);
    });

    testWidgets('should handle navigation state with Riverpod', (WidgetTester tester) async {
      // Create a mock database helper for testing
      final mockDatabaseHelper = DatabaseHelper();
      late WidgetRef testRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              testRef = ref;
              return const MaterialApp(
                home: MainNavigation(),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Initially should be on index 0 (App Groups)
      expect(testRef.read(navigationProvider), equals(0));

      // Tap on Insights tab in bottom navigation
      final insightsTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Insights'),
      );
      await tester.tap(insightsTab);
      await tester.pump();

      // Should be on index 1 (Insights)
      expect(testRef.read(navigationProvider), equals(1));
    });

    testWidgets('should show error page for unknown routes', (WidgetTester tester) async {
      // Create a mock database helper for testing
      final mockDatabaseHelper = DatabaseHelper();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: '/unknown',
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      );

      await tester.pump();

      // Should show 404 page
      expect(find.text('404 - Page Not Found'), findsOneWidget);
      expect(find.text('The requested page could not be found.'), findsOneWidget);
    });
  });

  group('State Management Tests', () {
    testWidgets('should initialize app providers correctly', (WidgetTester tester) async {
      final mockDatabaseHelper = DatabaseHelper();
      late WidgetRef testRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              testRef = ref;
              return const MaterialApp(
                home: Scaffold(body: Text('Test')),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Test that providers are accessible
      expect(testRef.read(databaseHelperProvider), equals(mockDatabaseHelper));
      expect(testRef.read(usageStatsServiceProvider), isNotNull);
      expect(testRef.read(navigationProvider), equals(0));
    });

    testWidgets('should handle navigation state changes', (WidgetTester tester) async {
      final mockDatabaseHelper = DatabaseHelper();
      late WidgetRef testRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              testRef = ref;
              return const MaterialApp(
                home: Scaffold(body: Text('Test')),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Initially should be on index 0
      expect(testRef.read(navigationProvider), equals(0));

      // Change navigation state
      testRef.read(navigationProvider.notifier).setIndex(1);
      await tester.pump();

      // Should be on index 1
      expect(testRef.read(navigationProvider), equals(1));
    });
  });
}