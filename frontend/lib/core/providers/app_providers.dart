import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/usage_stats_service.dart';
import '../../shared/database/database_helper.dart';
import '../models/app_group.dart';
import '../models/timer_session.dart';

// Database provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  throw UnimplementedError('DatabaseHelper must be overridden');
});

// Usage stats service provider
final usageStatsServiceProvider = Provider<UsageStatsService>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return UsageStatsService(databaseHelper: databaseHelper);
});

// App groups state provider
final appGroupsProvider = StateNotifierProvider<AppGroupsNotifier, AsyncValue<List<AppGroup>>>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return AppGroupsNotifier(databaseHelper);
});

// Timer sessions state provider
final timerSessionsProvider = StateNotifierProvider<TimerSessionsNotifier, Map<String, TimerSession?>>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return TimerSessionsNotifier(databaseHelper);
});

// Navigation state provider
final navigationProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});

// App initialization state provider
final appInitializationProvider = StateNotifierProvider<AppInitializationNotifier, AppInitializationState>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  final usageStatsService = ref.watch(usageStatsServiceProvider);
  return AppInitializationNotifier(databaseHelper, usageStatsService);
});

// App groups state notifier
class AppGroupsNotifier extends StateNotifier<AsyncValue<List<AppGroup>>> {
  final DatabaseHelper _databaseHelper;

  AppGroupsNotifier(this._databaseHelper) : super(const AsyncValue.loading()) {
    loadAppGroups();
  }

  Future<void> loadAppGroups() async {
    try {
      state = const AsyncValue.loading();
      final appGroups = await _databaseHelper.getAllAppGroups();
      state = AsyncValue.data(appGroups);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addAppGroup(AppGroup appGroup) async {
    try {
      await _databaseHelper.insertAppGroup(appGroup);
      await loadAppGroups();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAppGroup(AppGroup appGroup) async {
    try {
      await _databaseHelper.updateAppGroup(appGroup);
      await loadAppGroups();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAppGroup(String groupId) async {
    try {
      await _databaseHelper.deleteAppGroup(groupId);
      await loadAppGroups();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Timer sessions state notifier
class TimerSessionsNotifier extends StateNotifier<Map<String, TimerSession?>> {
  final DatabaseHelper _databaseHelper;

  TimerSessionsNotifier(this._databaseHelper) : super({});

  Future<void> loadTimerSession(String groupId) async {
    try {
      final session = await _databaseHelper.getTimerSession(groupId);
      state = {...state, groupId: session};
    } catch (error) {
      // Handle error silently for now
      state = {...state, groupId: null};
    }
  }

  Future<void> loadAllTimerSessions(List<String> groupIds) async {
    final sessions = <String, TimerSession?>{};
    for (final groupId in groupIds) {
      try {
        final session = await _databaseHelper.getTimerSession(groupId);
        sessions[groupId] = session;
      } catch (error) {
        sessions[groupId] = null;
      }
    }
    state = sessions;
  }

  Future<void> updateTimerSession(TimerSession session) async {
    try {
      await _databaseHelper.insertOrUpdateTimerSession(session);
      state = {...state, session.groupId: session};
    } catch (error) {
      // Handle error
    }
  }
}

// Navigation state notifier
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

// App initialization state
enum AppInitializationStatus {
  loading,
  permissionsRequired,
  ready,
  error,
}

class AppInitializationState {
  final AppInitializationStatus status;
  final String? errorMessage;
  final bool hasUsageStatsPermission;
  final bool hasOverlayPermission;

  const AppInitializationState({
    required this.status,
    this.errorMessage,
    this.hasUsageStatsPermission = false,
    this.hasOverlayPermission = false,
  });

  AppInitializationState copyWith({
    AppInitializationStatus? status,
    String? errorMessage,
    bool? hasUsageStatsPermission,
    bool? hasOverlayPermission,
  }) {
    return AppInitializationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hasUsageStatsPermission: hasUsageStatsPermission ?? this.hasUsageStatsPermission,
      hasOverlayPermission: hasOverlayPermission ?? this.hasOverlayPermission,
    );
  }
}

// App initialization notifier
class AppInitializationNotifier extends StateNotifier<AppInitializationState> {
  final DatabaseHelper _databaseHelper;
  final UsageStatsService _usageStatsService;

  AppInitializationNotifier(this._databaseHelper, this._usageStatsService)
      : super(const AppInitializationState(status: AppInitializationStatus.loading)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize database
      await _databaseHelper.database;

      // Check permissions
      final hasUsageStats = await _checkUsageStatsPermission();
      final hasOverlay = await _checkOverlayPermission();

      if (!hasUsageStats || !hasOverlay) {
        state = state.copyWith(
          status: AppInitializationStatus.permissionsRequired,
          hasUsageStatsPermission: hasUsageStats,
          hasOverlayPermission: hasOverlay,
        );
      } else {
        state = state.copyWith(
          status: AppInitializationStatus.ready,
          hasUsageStatsPermission: hasUsageStats,
          hasOverlayPermission: hasOverlay,
        );
      }
    } catch (error) {
      state = state.copyWith(
        status: AppInitializationStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<bool> _checkUsageStatsPermission() async {
    try {
      // For now, return true as usage stats checking is not implemented
      // This will be implemented in task 4
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> _checkOverlayPermission() async {
    try {
      // For now, return true as overlay permission checking is not implemented
      // This will be implemented in task 6
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> requestPermissions() async {
    state = state.copyWith(status: AppInitializationStatus.loading);
    
    try {
      // Request usage stats permission
      // This will be implemented in task 4
      
      // Request overlay permission
      // This will be implemented in task 6
      
      // For now, assume permissions are granted
      state = state.copyWith(
        status: AppInitializationStatus.ready,
        hasUsageStatsPermission: true,
        hasOverlayPermission: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AppInitializationStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  void retry() {
    _initialize();
  }
}