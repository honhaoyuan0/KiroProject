// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageStats _$UsageStatsFromJson(Map<String, dynamic> json) => UsageStats(
  appPackage: json['appPackage'] as String,
  groupId: json['groupId'] as String?,
  dailyUsage: Duration(microseconds: (json['dailyUsage'] as num).toInt()),
  weeklyUsage: Duration(microseconds: (json['weeklyUsage'] as num).toInt()),
  monthlyUsage: Duration(microseconds: (json['monthlyUsage'] as num).toInt()),
  lastUsed: DateTime.parse(json['lastUsed'] as String),
);

Map<String, dynamic> _$UsageStatsToJson(UsageStats instance) =>
    <String, dynamic>{
      'appPackage': instance.appPackage,
      'groupId': instance.groupId,
      'dailyUsage': instance.dailyUsage.inMicroseconds,
      'weeklyUsage': instance.weeklyUsage.inMicroseconds,
      'monthlyUsage': instance.monthlyUsage.inMicroseconds,
      'lastUsed': instance.lastUsed.toIso8601String(),
    };
