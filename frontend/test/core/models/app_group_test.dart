import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/models/models.dart';

void main() {
  group('AppGroup', () {
    late AppGroup testAppGroup;
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime(2024, 1, 15, 10, 30);
      testAppGroup = AppGroup(
        id: 'test-id',
        name: 'Social Media',
        appPackages: ['com.instagram.android', 'com.twitter.android'],
        timeLimit: const Duration(minutes: 30),
        createdAt: testDateTime,
        isActive: true,
      );
    });

    test('should create AppGroup with required fields', () {
      expect(testAppGroup.id, 'test-id');
      expect(testAppGroup.name, 'Social Media');
      expect(testAppGroup.appPackages, ['com.instagram.android', 'com.twitter.android']);
      expect(testAppGroup.timeLimit, const Duration(minutes: 30));
      expect(testAppGroup.createdAt, testDateTime);
      expect(testAppGroup.isActive, true);
    });

    test('should convert to and from Map correctly', () {
      final map = testAppGroup.toMap();
      final fromMap = AppGroup.fromMap(map);

      expect(fromMap.id, testAppGroup.id);
      expect(fromMap.name, testAppGroup.name);
      expect(fromMap.appPackages, testAppGroup.appPackages);
      expect(fromMap.timeLimit, testAppGroup.timeLimit);
      expect(fromMap.createdAt, testAppGroup.createdAt);
      expect(fromMap.isActive, testAppGroup.isActive);
    });

    test('should convert to and from JSON correctly', () {
      final json = testAppGroup.toJson();
      final fromJson = AppGroup.fromJson(json);

      expect(fromJson.id, testAppGroup.id);
      expect(fromJson.name, testAppGroup.name);
      expect(fromJson.appPackages, testAppGroup.appPackages);
      expect(fromJson.timeLimit, testAppGroup.timeLimit);
      expect(fromJson.createdAt, testAppGroup.createdAt);
      expect(fromJson.isActive, testAppGroup.isActive);
    });

    test('should create copy with modified fields', () {
      final copy = testAppGroup.copyWith(
        name: 'Updated Name',
        isActive: false,
      );

      expect(copy.id, testAppGroup.id);
      expect(copy.name, 'Updated Name');
      expect(copy.appPackages, testAppGroup.appPackages);
      expect(copy.timeLimit, testAppGroup.timeLimit);
      expect(copy.createdAt, testAppGroup.createdAt);
      expect(copy.isActive, false);
    });

    test('should support equality comparison', () {
      final identical = AppGroup(
        id: 'test-id',
        name: 'Social Media',
        appPackages: ['com.instagram.android', 'com.twitter.android'],
        timeLimit: const Duration(minutes: 30),
        createdAt: testDateTime,
        isActive: true,
      );

      final different = testAppGroup.copyWith(name: 'Different Name');

      expect(testAppGroup, equals(identical));
      expect(testAppGroup, isNot(equals(different)));
    });

    test('should handle empty app packages list', () {
      final emptyGroup = AppGroup(
        id: 'empty-id',
        name: 'Empty Group',
        appPackages: [],
        timeLimit: const Duration(minutes: 15),
        createdAt: testDateTime,
      );

      final map = emptyGroup.toMap();
      final fromMap = AppGroup.fromMap(map);

      expect(fromMap.appPackages, isEmpty);
    });
  });
}