import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();
  
  @override
  List<Object> get props => [];
}

/// General failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class PermissionFailure extends Failure {
  final String permission;
  
  const PermissionFailure(this.permission);
  
  @override
  List<Object> get props => [permission];
}

class DatabaseFailure extends Failure {
  final String message;
  
  const DatabaseFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class UsageStatsFailure extends Failure {
  final String message;
  
  const UsageStatsFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class OverlayFailure extends Failure {
  final String message;
  
  const OverlayFailure(this.message);
  
  @override
  List<Object> get props => [message];
}