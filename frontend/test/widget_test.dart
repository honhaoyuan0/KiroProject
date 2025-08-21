// Basic Flutter widget test for WiseScreen app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/services/usage_stats_service.dart';
import 'package:wise_screen/shared/database/database_helper.dart';
import 'package:wise_screen/main.dart';

void main() {
  testWidgets('WiseScreen app smoke test', (WidgetTester tester) async {
    // Create mock dependencies
    final databaseHelper = DatabaseHelper();
    final usageStatsService = UsageStatsService(databaseHelper: databaseHelper);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(WiseScreenApp(
      databaseHelper: databaseHelper,
      usageStatsService: usageStatsService,
    ));

    // Verify that the app loads with bottom navigation
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    
    // Verify that the insights tab is selected by default
    expect(find.byIcon(Icons.analytics), findsOneWidget);
  });
}
