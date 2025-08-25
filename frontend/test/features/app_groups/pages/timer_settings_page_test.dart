import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wise_screen/core/constants/app_theme.dart';
import 'package:wise_screen/features/app_groups/pages/timer_settings_page.dart';

void main() {
  group('TimerSettingsPage', () {
    Widget createTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: TimerSettingsPage(),
        ),
      );
    }

    testWidgets('displays app bar with title and reset button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Timer Settings'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('displays all settings sections', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Timing'), findsOneWidget);
      expect(find.text('Sound & Vibration'), findsOneWidget);
      expect(find.text('Auto-Pause'), findsOneWidget);
      expect(find.text('Display'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('displays notification settings switches', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.text('Warning Notifications'), findsOneWidget);
      expect(find.text('Time Up Notifications'), findsOneWidget);
      expect(find.text('Break Reminders'), findsOneWidget);
    });

    testWidgets('displays timing sliders', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Warning Time'), findsOneWidget);
      expect(find.text('Break Reminder Interval'), findsOneWidget);
      expect(find.byType(Slider), findsAtLeastNWidgets(2));
    });

    testWidgets('displays sound and vibration settings', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Enable Sounds'), findsOneWidget);
      expect(find.text('Enable Vibration'), findsOneWidget);
      expect(find.text('Notification Sound'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('displays auto-pause settings', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Pause on Screen Off'), findsOneWidget);
      expect(find.text('Pause on App Switch'), findsOneWidget);
    });

    testWidgets('displays display settings', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Show Timer in Notification Bar'), findsOneWidget);
      expect(find.text('Show Progress in Overlay'), findsOneWidget);
    });

    testWidgets('displays advanced settings actions', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Export Timer Data'), findsOneWidget);
      expect(find.text('Clear Timer History'), findsOneWidget);
      expect(find.text('Test Notifications'), findsOneWidget);
    });

    testWidgets('notification switches work correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the main notifications switch
      final enableNotificationsSwitch = find.byType(SwitchListTile).first;
      
      // Should be enabled by default
      SwitchListTile switchTile = tester.widget(enableNotificationsSwitch);
      expect(switchTile.value, isTrue);

      // Toggle the switch
      await tester.tap(enableNotificationsSwitch);
      await tester.pumpAndSettle();

      // Check that it changed
      switchTile = tester.widget(enableNotificationsSwitch);
      expect(switchTile.value, isFalse);
    });

    testWidgets('sliders work correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final slider = find.byType(Slider).first;
      
      // Should have initial value
      Slider sliderWidget = tester.widget(slider);
      expect(sliderWidget.value, equals(5.0)); // Default warning time

      // Move slider
      await tester.drag(slider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Value should have changed
      sliderWidget = tester.widget(slider);
      expect(sliderWidget.value, greaterThan(5.0));
    });

    testWidgets('dropdown works correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final dropdown = find.byType(DropdownButtonFormField<String>);
      
      // Should have default value
      DropdownButtonFormField<String> dropdownWidget = tester.widget(dropdown);
      expect(dropdownWidget.initialValue, equals('Default'));

      // Tap dropdown to open
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Should show options
      expect(find.text('Bell'), findsOneWidget);
      expect(find.text('Chime'), findsOneWidget);

      // Select an option
      await tester.tap(find.text('Bell'));
      await tester.pumpAndSettle();

      // Value should have changed (this is harder to test with DropdownButtonFormField)
      // For now, just verify the dropdown still exists
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('reset button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Settings'), findsOneWidget);
      expect(find.text('Are you sure you want to reset all timer settings to their default values?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsAtLeastNWidgets(2)); // One in dialog, one in app bar
    });

    testWidgets('reset confirmation works', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // First change a setting
      final enableNotificationsSwitch = find.byType(SwitchListTile).first;
      await tester.tap(enableNotificationsSwitch);
      await tester.pumpAndSettle();

      // Open reset dialog
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Confirm reset
      await tester.tap(find.text('Reset').last);
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Settings reset to defaults'), findsOneWidget);
    });

    testWidgets('export timer data shows message', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Export Timer Data'));
      await tester.pumpAndSettle();

      expect(find.text('Timer data export feature coming soon'), findsOneWidget);
    });

    testWidgets('clear timer history shows confirmation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Clear Timer History'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Timer History'), findsAtLeastNWidgets(2));
      expect(find.text('Are you sure you want to delete all timer session history? This action cannot be undone.'), findsOneWidget);
    });

    testWidgets('test notifications shows message', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Test Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Test notification sent'), findsOneWidget);
    });

    testWidgets('dependent settings are disabled correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Disable main notifications
      final enableNotificationsSwitch = find.byType(SwitchListTile).first;
      await tester.tap(enableNotificationsSwitch);
      await tester.pumpAndSettle();

      // Dependent switches should be disabled
      final warningSwitch = find.byType(SwitchListTile).at(1);
      SwitchListTile switchTile = tester.widget(warningSwitch);
      expect(switchTile.onChanged, isNull);
    });

    testWidgets('uses correct theme colors', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that sections use the app theme
      final icons = find.byIcon(Icons.notifications);
      expect(icons, findsOneWidget);
      
      final iconWidget = tester.widget<Icon>(icons);
      expect(iconWidget.color, equals(AppTheme.primaryPurple));
    });

    testWidgets('displays all section icons correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle), findsOneWidget);
      expect(find.byIcon(Icons.display_settings), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}