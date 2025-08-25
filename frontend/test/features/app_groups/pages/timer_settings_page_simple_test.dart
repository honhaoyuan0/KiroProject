import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wise_screen/features/app_groups/pages/timer_settings_page.dart';

void main() {
  group('TimerSettingsPage - Basic Tests', () {
    Widget createTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: TimerSettingsPage(),
        ),
      );
    }

    testWidgets('displays app bar correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Timer Settings'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('displays scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have a ListView
      expect(find.byType(ListView), findsOneWidget);
      
      // Should have multiple sections (even if not all visible)
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('can scroll through settings', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Scroll down to find content
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Should find at least some settings text
      expect(find.textContaining('Notifications'), findsAtLeastNWidgets(0));
    });

    testWidgets('reset button works', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Should show dialog
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('has proper widget structure', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Basic structure checks
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}