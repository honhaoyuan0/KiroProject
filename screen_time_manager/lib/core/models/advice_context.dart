import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'advice_context.g.dart';

@JsonSerializable()
class AdviceContext extends Equatable {
  final Duration usageDuration;
  final String timeOfDay;
  final List<String> appCategories;
  final String? userMood;

  const AdviceContext({
    required this.usageDuration,
    required this.timeOfDay,
    required this.appCategories,
    this.userMood,
  });

  factory AdviceContext.fromJson(Map<String, dynamic> json) => _$AdviceContextFromJson(json);
  Map<String, dynamic> toJson() => _$AdviceContextToJson(this);

  // Database conversion methods (for caching advice contexts)
  Map<String, dynamic> toMap() {
    return {
      'usage_duration_seconds': usageDuration.inSeconds,
      'time_of_day': timeOfDay,
      'app_categories': appCategories.isEmpty ? '' : appCategories.join(','),
      'user_mood': userMood,
    };
  }

  factory AdviceContext.fromMap(Map<String, dynamic> map) {
    final appCategoriesString = map['app_categories'] as String;
    return AdviceContext(
      usageDuration: Duration(seconds: map['usage_duration_seconds'] as int),
      timeOfDay: map['time_of_day'] as String,
      appCategories: appCategoriesString.isEmpty ? [] : appCategoriesString.split(','),
      userMood: map['user_mood'] as String?,
    );
  }

  AdviceContext copyWith({
    Duration? usageDuration,
    String? timeOfDay,
    List<String>? appCategories,
    String? userMood,
  }) {
    return AdviceContext(
      usageDuration: usageDuration ?? this.usageDuration,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      appCategories: appCategories ?? this.appCategories,
      userMood: userMood ?? this.userMood,
    );
  }

  @override
  List<Object?> get props => [usageDuration, timeOfDay, appCategories, userMood];
}