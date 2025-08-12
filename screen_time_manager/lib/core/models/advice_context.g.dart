// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advice_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdviceContext _$AdviceContextFromJson(Map<String, dynamic> json) =>
    AdviceContext(
      usageDuration: Duration(
        microseconds: (json['usageDuration'] as num).toInt(),
      ),
      timeOfDay: json['timeOfDay'] as String,
      appCategories: (json['appCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      userMood: json['userMood'] as String?,
    );

Map<String, dynamic> _$AdviceContextToJson(AdviceContext instance) =>
    <String, dynamic>{
      'usageDuration': instance.usageDuration.inMicroseconds,
      'timeOfDay': instance.timeOfDay,
      'appCategories': instance.appCategories,
      'userMood': instance.userMood,
    };
