import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'usage_stats.g.dart';

@JsonSerializable()
class UsageStats extends Equatable {
  final String appPackage;
  final String? groupId;
  final Duration dailyUsage;
  final Duration weeklyUsage;
  final Duration monthlyUsage;
  final DateTime lastUsed;

  const UsageStats({
    required this.appPackage,
    this.groupId,
    required this.dailyUsage,
    required this.weeklyUsage,
    required this.monthlyUsage,
    required this.lastUsed,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) => _$UsageStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UsageStatsToJson(this);

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'app_package': appPackage,
      'group_id': groupId,
      'daily_usage_seconds': dailyUsage.inSeconds,
      'weekly_usage_seconds': weeklyUsage.inSeconds,
      'monthly_usage_seconds': monthlyUsage.inSeconds,
      'last_used': lastUsed.millisecondsSinceEpoch,
    };
  }

  factory UsageStats.fromMap(Map<String, dynamic> map) {
    return UsageStats(
      appPackage: map['app_package'] as String,
      groupId: map['group_id'] as String?,
      dailyUsage: Duration(seconds: map['daily_usage_seconds'] as int),
      weeklyUsage: Duration(seconds: map['weekly_usage_seconds'] as int),
      monthlyUsage: Duration(seconds: map['monthly_usage_seconds'] as int),
      lastUsed: DateTime.fromMillisecondsSinceEpoch(map['last_used'] as int),
    );
  }

  UsageStats copyWith({
    String? appPackage,
    String? groupId,
    Duration? dailyUsage,
    Duration? weeklyUsage,
    Duration? monthlyUsage,
    DateTime? lastUsed,
  }) {
    return UsageStats(
      appPackage: appPackage ?? this.appPackage,
      groupId: groupId ?? this.groupId,
      dailyUsage: dailyUsage ?? this.dailyUsage,
      weeklyUsage: weeklyUsage ?? this.weeklyUsage,
      monthlyUsage: monthlyUsage ?? this.monthlyUsage,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  List<Object?> get props => [appPackage, groupId, dailyUsage, weeklyUsage, monthlyUsage, lastUsed];
}