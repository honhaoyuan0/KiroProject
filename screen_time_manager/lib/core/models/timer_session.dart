import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'timer_session.g.dart';

@JsonSerializable()
class TimerSession extends Equatable {
  final String groupId;
  final DateTime startTime;
  final Duration elapsedTime;
  final bool isActive;
  final DateTime? lastPauseTime;

  const TimerSession({
    required this.groupId,
    required this.startTime,
    required this.elapsedTime,
    this.isActive = false,
    this.lastPauseTime,
  });

  factory TimerSession.fromJson(Map<String, dynamic> json) => _$TimerSessionFromJson(json);
  Map<String, dynamic> toJson() => _$TimerSessionToJson(this);

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'start_time': startTime.millisecondsSinceEpoch,
      'elapsed_time_seconds': elapsedTime.inSeconds,
      'is_active': isActive ? 1 : 0,
      'last_pause_time': lastPauseTime?.millisecondsSinceEpoch,
    };
  }

  factory TimerSession.fromMap(Map<String, dynamic> map) {
    return TimerSession(
      groupId: map['group_id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      elapsedTime: Duration(seconds: map['elapsed_time_seconds'] as int),
      isActive: (map['is_active'] as int) == 1,
      lastPauseTime: map['last_pause_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_pause_time'] as int)
          : null,
    );
  }

  TimerSession copyWith({
    String? groupId,
    DateTime? startTime,
    Duration? elapsedTime,
    bool? isActive,
    DateTime? lastPauseTime,
  }) {
    return TimerSession(
      groupId: groupId ?? this.groupId,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isActive: isActive ?? this.isActive,
      lastPauseTime: lastPauseTime ?? this.lastPauseTime,
    );
  }

  @override
  List<Object?> get props => [groupId, startTime, elapsedTime, isActive, lastPauseTime];
}