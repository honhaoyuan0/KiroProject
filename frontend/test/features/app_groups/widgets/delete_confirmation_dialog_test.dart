import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/constants/app_theme.dart';
import 'package:wise_screen/features/app_groups/widgets/delete_confirmation_dialog.dart';

void main() {
  group('DeleteConfirmationDialog Widget Tests', () {
    Widget createTestWidget({
      String? title,
      String? content,
      String? confirmText,
      String? cancelText,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: DeleteConfirmationDialog(
            title: title ?? 'Delete Item',
            content: content ?? 'Are you sure you want to delete this item?',
            confirmText: confirmText,
            cancelText: cancelText,
          ),
        ),
      );
    }

    testWidgets('displays title and content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        title: 'Delete App Group',
        content: 'This action cannot be undone.',
      ));

      expect(find.text('Delete App Group'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
    });

    testWidgets('shows warning icon in title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('displays default button labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('displays custom button labels when provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        confirmText: 'Remove',
        cancelText: 'Keep',
      ));

      expect(find.text('Keep'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('returns false when cancel is tapped', (WidgetTester tester) async {
      bool? result;
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (context) => const DeleteConfirmationDialog(
                  title: 'Test',
                  content: 'Test content',
                ),
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('returns true when delete is tapped', (WidgetTester tester) async {
      bool? result;
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (context) => const DeleteConfirmationDialog(
                  title: 'Test',
                  content: 'Test content',
                ),
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('applies correct styling to buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the delete button (ElevatedButton)
      final deleteButton = find.ancestor(
        of: find.text('Delete'),
        matching: find.byType(ElevatedButton),
      );
      expect(deleteButton, findsOneWidget);

      // Find the cancel button (TextButton)
      final cancelButton = find.ancestor(
        of: find.text('Cancel'),
        matching: find.byType(TextButton),
      );
      expect(cancelButton, findsOneWidget);
    });

    testWidgets('warning icon has correct color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final warningIcon = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(warningIcon.color, AppTheme.errorColor);
    });

    testWidgets('warning icon container has correct background', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the container that wraps the warning icon
      final iconContainer = find.ancestor(
        of: find.byIcon(Icons.warning),
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(iconContainer);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppTheme.errorColor.withValues(alpha: 0.1));
    });

    testWidgets('has rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      final shape = alertDialog.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('content text has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        content: 'Test content with styling',
      ));

      final contentText = find.text('Test content with styling');
      expect(contentText, findsOneWidget);

      final textWidget = tester.widget<Text>(contentText);
      expect(textWidget.style?.color, AppTheme.textSecondary);
      expect(textWidget.style?.height, 1.4);
    });

    testWidgets('title text has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'Test Title'));

      final titleText = find.text('Test Title');
      expect(titleText, findsOneWidget);

      final textWidget = tester.widget<Text>(titleText);
      expect(textWidget.style?.color, AppTheme.textPrimary);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
    });
  });
}