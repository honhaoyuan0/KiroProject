// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimerSession _$TimerSessionFromJson(Map<String, dynamic> json) => TimerSession(
  groupId: json['groupId'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  elapsedTime: Duration(microseconds: (json['elapsedTime'] as num).toInt()),
  isActive: json['isActive'] as bool? ?? false,
  lastPauseTime: json['lastPauseTime'] == null
      ? null
      : DateTime.parse(json['lastPauseTime'] as String),
);

Map<String, dynamic> _$TimerSessionToJson(TimerSession instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'startTime': instance.startTime.toIso8601String(),
      'elapsedTime': instance.elapsedTime.inMicroseconds,
      'isActive': instance.isActive,
      'lastPauseTime': instance.lastPauseTime?.toIso8601String(),
    };
