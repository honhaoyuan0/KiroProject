import 'package:flutter_test/flutter_test.dart';
import 'package:wise_screen/core/models/models.dart';

void main() {
  group('TimerSession', () {
    late TimerSession testSession;
    late DateTime testStartTime;
    late DateTime testPauseTime;

    setUp(() {
      testStartTime = DateTime(2024, 1, 15, 10, 30);
      testPauseTime = DateTime(2024, 1, 15, 10, 45);
      testSession = TimerSession(
        groupId: 'test-group-id',
        startTime: testStartTime,
        elapsedTime: const Duration(minutes: 15),
        isActive: true,
        lastPauseTime: testPauseTime,
      );
    });

    test('should create TimerSession with required fields', () {
      expect(testSession.groupId, 'test-group-id');
      expect(testSession.startTime, testStartTime);
      expect(testSession.elapsedTime, const Duration(minutes: 15));
      expect(testSession.isActive, true);
      expect(testSession.lastPauseTime, testPauseTime);
    });

    test('should convert to and from Map correctly', () {
      final map = testSession.toMap();
      final fromMap = TimerSession.fromMap(map);

      expect(fromMap.groupId, testSession.groupId);
      expect(fromMap.startTime, testSession.startTime);
      expect(fromMap.elapsedTime, testSession.elapsedTime);
      expect(fromMap.isActive, testSession.isActive);
      expect(fromMap.lastPauseTime, testSession.lastPauseTime);
    });

    test('should convert to and from JSON correctly', () {
      final json = testSession.toJson();
      final fromJson = TimerSession.fromJson(json);

      expect(fromJson.groupId, testSession.groupId);
      expect(fromJson.startTime, testSession.startTime);
      expect(fromJson.elapsedTime, testSession.elapsedTime);
      expect(fromJson.isActive, testSession.isActive);
      expect(fromJson.lastPauseTime, testSession.lastPauseTime);
    });

    test('should create copy with modified fields', () {
      final copy = testSession.copyWith(
        isActive: false,
        elapsedTime: const Duration(minutes: 20),
      );

      expect(copy.groupId, testSession.groupId);
      expect(copy.startTime, testSession.startTime);
      expect(copy.elapsedTime, const Duration(minutes: 20));
      expect(copy.isActive, false);
      expect(copy.lastPauseTime, testSession.lastPauseTime);
    });

    test('should support equality comparison', () {
      final identical = TimerSession(
        groupId: 'test-group-id',
        startTime: testStartTime,
        elapsedTime: const Duration(minutes: 15),
        isActive: true,
        lastPauseTime: testPauseTime,
      );

      final different = testSession.copyWith(isActive: false);

      expect(testSession, equals(identical));
      expect(testSession, isNot(equals(different)));
    });

    test('should handle null lastPauseTime', () {
      final sessionWithoutPause = TimerSession(
        groupId: 'test-group-id',
        startTime: testStartTime,
        elapsedTime: const Duration(minutes: 10),
        isActive: true,
      );

      final map = sessionWithoutPause.toMap();
      final fromMap = TimerSession.fromMap(map);

      expect(fromMap.lastPauseTime, isNull);
    });

    test('should default isActive to false', () {
      final defaultSession = TimerSession(
        groupId: 'test-group-id',
        startTime: testStartTime,
        elapsedTime: Duration.zero,
      );

      expect(defaultSession.isActive, false);
    });
  });
}