// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppGroup _$AppGroupFromJson(Map<String, dynamic> json) => AppGroup(
  id: json['id'] as String,
  name: json['name'] as String,
  appPackages: (json['appPackages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  timeLimit: Duration(microseconds: (json['timeLimit'] as num).toInt()),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$AppGroupToJson(AppGroup instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'appPackages': instance.appPackages,
  'timeLimit': instance.timeLimit.inMicroseconds,
  'createdAt': instance.createdAt.toIso8601String(),
  'isActive': instance.isActive,
};
