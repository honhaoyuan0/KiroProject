import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'app_group.g.dart';

@JsonSerializable()
class AppGroup extends Equatable {
  final String id;
  final String name;
  final List<String> appPackages;
  final Duration timeLimit;
  final DateTime createdAt;
  final bool isActive;

  const AppGroup({
    required this.id,
    required this.name,
    required this.appPackages,
    required this.timeLimit,
    required this.createdAt,
    this.isActive = true,
  });

  factory AppGroup.fromJson(Map<String, dynamic> json) => _$AppGroupFromJson(json);
  Map<String, dynamic> toJson() => _$AppGroupToJson(this);

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'app_packages': appPackages.isEmpty ? '' : appPackages.join(','),
      'time_limit_minutes': timeLimit.inMinutes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory AppGroup.fromMap(Map<String, dynamic> map) {
    final appPackagesString = map['app_packages'] as String;
    return AppGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      appPackages: appPackagesString.isEmpty ? [] : appPackagesString.split(','),
      timeLimit: Duration(minutes: map['time_limit_minutes'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      isActive: (map['is_active'] as int) == 1,
    );
  }

  AppGroup copyWith({
    String? id,
    String? name,
    List<String>? appPackages,
    Duration? timeLimit,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return AppGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      appPackages: appPackages ?? this.appPackages,
      timeLimit: timeLimit ?? this.timeLimit,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, appPackages, timeLimit, createdAt, isActive];
}