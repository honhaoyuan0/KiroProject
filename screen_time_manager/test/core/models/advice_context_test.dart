import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/models/models.dart';

void main() {
  group('AdviceContext', () {
    late AdviceContext testContext;

    setUp(() {
      testContext = const AdviceContext(
        usageDuration: Duration(minutes: 45),
        timeOfDay: 'afternoon',
        appCategories: ['social', 'entertainment'],
        userMood: 'stressed',
      );
    });

    test('should create AdviceContext with required fields', () {
      expect(testContext.usageDuration, const Duration(minutes: 45));
      expect(testContext.timeOfDay, 'afternoon');
      expect(testContext.appCategories, ['social', 'entertainment']);
      expect(testContext.userMood, 'stressed');
    });

    test('should convert to and from Map correctly', () {
      final map = testContext.toMap();
      final fromMap = AdviceContext.fromMap(map);

      expect(fromMap.usageDuration, testContext.usageDuration);
      expect(fromMap.timeOfDay, testContext.timeOfDay);
      expect(fromMap.appCategories, testContext.appCategories);
      expect(fromMap.userMood, testContext.userMood);
    });

    test('should convert to and from JSON correctly', () {
      final json = testContext.toJson();
      final fromJson = AdviceContext.fromJson(json);

      expect(fromJson.usageDuration, testContext.usageDuration);
      expect(fromJson.timeOfDay, testContext.timeOfDay);
      expect(fromJson.appCategories, testContext.appCategories);
      expect(fromJson.userMood, testContext.userMood);
    });

    test('should create copy with modified fields', () {
      final copy = testContext.copyWith(
        timeOfDay: 'evening',
        userMood: 'relaxed',
      );

      expect(copy.usageDuration, testContext.usageDuration);
      expect(copy.timeOfDay, 'evening');
      expect(copy.appCategories, testContext.appCategories);
      expect(copy.userMood, 'relaxed');
    });

    test('should support equality comparison', () {
      const identical = AdviceContext(
        usageDuration: Duration(minutes: 45),
        timeOfDay: 'afternoon',
        appCategories: ['social', 'entertainment'],
        userMood: 'stressed',
      );

      final different = testContext.copyWith(timeOfDay: 'morning');

      expect(testContext, equals(identical));
      expect(testContext, isNot(equals(different)));
    });

    test('should handle null userMood', () {
      const contextWithoutMood = AdviceContext(
        usageDuration: Duration(minutes: 30),
        timeOfDay: 'morning',
        appCategories: ['productivity'],
      );

      final map = contextWithoutMood.toMap();
      final fromMap = AdviceContext.fromMap(map);

      expect(fromMap.userMood, isNull);
    });

    test('should handle empty app categories', () {
      const contextWithEmptyCategories = AdviceContext(
        usageDuration: Duration(minutes: 15),
        timeOfDay: 'night',
        appCategories: [],
      );

      final map = contextWithEmptyCategories.toMap();
      final fromMap = AdviceContext.fromMap(map);

      expect(fromMap.appCategories, isEmpty);
    });

    test('should handle zero duration', () {
      const contextWithZeroDuration = AdviceContext(
        usageDuration: Duration.zero,
        timeOfDay: 'morning',
        appCategories: ['productivity'],
      );

      final map = contextWithZeroDuration.toMap();
      final fromMap = AdviceContext.fromMap(map);

      expect(fromMap.usageDuration, Duration.zero);
    });
  });
}