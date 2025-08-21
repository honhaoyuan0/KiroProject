import 'dart:async';
import 'dart:math';
import '../models/models.dart';
import '../../shared/database/database_helper.dart';

/// Enum for different time periods for usage statistics
enum TimePeriod { daily, weekly, monthly }

/// Data class for aggregated usage statistics
class AggregatedUsageStats {
  final Duration totalUsage;
  final Map<String, Duration> appUsage;
  final Map<String, Duration> groupUsage;
  final DateTime periodStart;
  final DateTime periodEnd;
  final TimePeriod period;

  const AggregatedUsageStats({
    required this.totalUsage,
    required this.appUsage,
    required this.groupUsage,
    required this.periodStart,
    required this.periodEnd,
    required this.period,
  });
}

/// Data class for usage trends and patterns
class UsageTrends {
  final double changePercentage;
  final bool isIncreasing;
  final Duration averageSessionLength;
  final int totalSessions;
  final List<String> mostUsedApps;
  final List<String> mostUsedGroups;
  final Map<int, Duration> hourlyUsage; // Hour of day -> usage duration

  const UsageTrends({
    required this.changePercentage,
    required this.isIncreasing,
    required this.averageSessionLength,
    required this.totalSessions,
    required this.mostUsedApps,
    required this.mostUsedGroups,
    required this.hourlyUsage,
  });
}

/// Service class for collecting and processing app usage statistics
class UsageStatsService {
  final DatabaseHelper _databaseHelper;
  
  UsageStatsService({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Collects and processes usage data for a specific time period
  Future<AggregatedUsageStats> getUsageStatistics(TimePeriod period) async {
    final now = DateTime.now();
    final periodDates = _getPeriodDates(period, now);
    
    final allStats = await _databaseHelper.getAllUsageStats();
    final appGroups = await _databaseHelper.getAllAppGroups();
    
    // Create a map of app package to group ID for quick lookup
    final appToGroupMap = <String, String>{};
    for (final group in appGroups) {
      for (final appPackage in group.appPackages) {
        appToGroupMap[appPackage] = group.id;
      }
    }
    
    // Filter stats based on the time period and calculate totals
    Duration totalUsage = Duration.zero;
    final appUsage = <String, Duration>{};
    final groupUsage = <String, Duration>{};
    
    for (final stat in allStats) {
      Duration periodUsage;
      
      switch (period) {
        case TimePeriod.daily:
          periodUsage = stat.dailyUsage;
          break;
        case TimePeriod.weekly:
          periodUsage = stat.weeklyUsage;
          break;
        case TimePeriod.monthly:
          periodUsage = stat.monthlyUsage;
          break;
      }
      
      if (periodUsage > Duration.zero) {
        totalUsage += periodUsage;
        appUsage[stat.appPackage] = periodUsage;
        
        // Aggregate by group if app belongs to a group
        final groupId = stat.groupId ?? appToGroupMap[stat.appPackage];
        if (groupId != null) {
          groupUsage[groupId] = (groupUsage[groupId] ?? Duration.zero) + periodUsage;
        }
      }
    }
    
    return AggregatedUsageStats(
      totalUsage: totalUsage,
      appUsage: appUsage,
      groupUsage: groupUsage,
      periodStart: periodDates.start,
      periodEnd: periodDates.end,
      period: period,
    );
  }

  /// Calculates usage trends and patterns for analysis
  Future<UsageTrends> getUsageTrends(TimePeriod period) async {
    final currentStats = await getUsageStatistics(period);
    final previousStats = await _getPreviousPeriodStats(period);
    
    // Calculate change percentage
    final currentTotal = currentStats.totalUsage.inMinutes;
    final previousTotal = previousStats.totalUsage.inMinutes;
    
    double changePercentage = 0.0;
    if (previousTotal > 0) {
      changePercentage = ((currentTotal - previousTotal) / previousTotal) * 100;
    }
    
    // Get most used apps and groups
    final sortedApps = currentStats.appUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostUsedApps = sortedApps.take(5).map((e) => e.key).toList();
    
    final sortedGroups = currentStats.groupUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostUsedGroups = sortedGroups.take(5).map((e) => e.key).toList();
    
    // Calculate average session length (simplified estimation)
    final totalSessions = max(1, currentStats.appUsage.length);
    final averageSessionLength = Duration(
      minutes: currentTotal ~/ totalSessions,
    );
    
    // Generate hourly usage pattern (mock data for now - would need real session data)
    final hourlyUsage = _generateHourlyUsagePattern(currentStats.totalUsage);
    
    return UsageTrends(
      changePercentage: changePercentage,
      isIncreasing: changePercentage > 0,
      averageSessionLength: averageSessionLength,
      totalSessions: totalSessions,
      mostUsedApps: mostUsedApps,
      mostUsedGroups: mostUsedGroups,
      hourlyUsage: hourlyUsage,
    );
  }

  /// Gets usage statistics for a specific app group
  Future<AggregatedUsageStats> getGroupUsageStatistics(
    String groupId,
    TimePeriod period,
  ) async {
    final groupStats = await _databaseHelper.getUsageStatsByGroup(groupId);
    final now = DateTime.now();
    final periodDates = _getPeriodDates(period, now);
    
    Duration totalUsage = Duration.zero;
    final appUsage = <String, Duration>{};
    final groupUsage = <String, Duration>{groupId: Duration.zero};
    
    for (final stat in groupStats) {
      Duration periodUsage;
      
      switch (period) {
        case TimePeriod.daily:
          periodUsage = stat.dailyUsage;
          break;
        case TimePeriod.weekly:
          periodUsage = stat.weeklyUsage;
          break;
        case TimePeriod.monthly:
          periodUsage = stat.monthlyUsage;
          break;
      }
      
      if (periodUsage > Duration.zero) {
        totalUsage += periodUsage;
        appUsage[stat.appPackage] = periodUsage;
      }
    }
    
    groupUsage[groupId] = totalUsage;
    
    return AggregatedUsageStats(
      totalUsage: totalUsage,
      appUsage: appUsage,
      groupUsage: groupUsage,
      periodStart: periodDates.start,
      periodEnd: periodDates.end,
      period: period,
    );
  }

  /// Updates usage statistics for a specific app
  Future<void> updateAppUsage(
    String appPackage,
    Duration sessionDuration,
    String? groupId,
  ) async {
    final existingStats = await _databaseHelper.getUsageStats(appPackage);
    final now = DateTime.now();
    
    if (existingStats != null) {
      // Update existing stats
      final updatedStats = existingStats.copyWith(
        dailyUsage: _shouldResetDaily(existingStats.lastUsed, now)
            ? sessionDuration
            : existingStats.dailyUsage + sessionDuration,
        weeklyUsage: _shouldResetWeekly(existingStats.lastUsed, now)
            ? sessionDuration
            : existingStats.weeklyUsage + sessionDuration,
        monthlyUsage: _shouldResetMonthly(existingStats.lastUsed, now)
            ? sessionDuration
            : existingStats.monthlyUsage + sessionDuration,
        lastUsed: now,
        groupId: groupId,
      );
      
      await _databaseHelper.insertOrUpdateUsageStats(updatedStats);
    } else {
      // Create new stats entry
      final newStats = UsageStats(
        appPackage: appPackage,
        groupId: groupId,
        dailyUsage: sessionDuration,
        weeklyUsage: sessionDuration,
        monthlyUsage: sessionDuration,
        lastUsed: now,
      );
      
      await _databaseHelper.insertOrUpdateUsageStats(newStats);
    }
  }

  /// Resets usage statistics for a new time period
  Future<void> resetPeriodStats(TimePeriod period) async {
    final allStats = await _databaseHelper.getAllUsageStats();
    
    for (final stat in allStats) {
      UsageStats updatedStats;
      
      switch (period) {
        case TimePeriod.daily:
          updatedStats = stat.copyWith(dailyUsage: Duration.zero);
          break;
        case TimePeriod.weekly:
          updatedStats = stat.copyWith(weeklyUsage: Duration.zero);
          break;
        case TimePeriod.monthly:
          updatedStats = stat.copyWith(monthlyUsage: Duration.zero);
          break;
      }
      
      await _databaseHelper.insertOrUpdateUsageStats(updatedStats);
    }
  }

  /// Gets the top N most used apps for a given period
  Future<List<MapEntry<String, Duration>>> getTopApps(
    TimePeriod period, {
    int limit = 10,
  }) async {
    final stats = await getUsageStatistics(period);
    final sortedApps = stats.appUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedApps.take(limit).toList();
  }

  /// Gets the top N most used app groups for a given period
  Future<List<MapEntry<String, Duration>>> getTopGroups(
    TimePeriod period, {
    int limit = 10,
  }) async {
    final stats = await getUsageStatistics(period);
    final sortedGroups = stats.groupUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedGroups.take(limit).toList();
  }

  // Private helper methods

  ({DateTime start, DateTime end}) _getPeriodDates(TimePeriod period, DateTime now) {
    switch (period) {
      case TimePeriod.daily:
        final startOfDay = DateTime(now.year, now.month, now.day);
        return (start: startOfDay, end: startOfDay.add(const Duration(days: 1)));
      
      case TimePeriod.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return (start: startOfWeekDay, end: startOfWeekDay.add(const Duration(days: 7)));
      
      case TimePeriod.monthly:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
        return (start: startOfMonth, end: nextMonth);
    }
  }

  Future<AggregatedUsageStats> _getPreviousPeriodStats(TimePeriod period) async {
    final now = DateTime.now();
    DateTime previousPeriodDate;
    
    switch (period) {
      case TimePeriod.daily:
        previousPeriodDate = now.subtract(const Duration(days: 1));
        break;
      case TimePeriod.weekly:
        previousPeriodDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.monthly:
        previousPeriodDate = DateTime(now.year, now.month - 1, now.day);
        break;
    }
    
    // For simplicity, return empty stats for previous period
    // In a real implementation, you'd store historical data
    return AggregatedUsageStats(
      totalUsage: Duration.zero,
      appUsage: {},
      groupUsage: {},
      periodStart: previousPeriodDate,
      periodEnd: now,
      period: period,
    );
  }

  Map<int, Duration> _generateHourlyUsagePattern(Duration totalUsage) {
    final hourlyUsage = <int, Duration>{};
    final totalMinutes = totalUsage.inMinutes;
    
    // Distribute usage across hours with some realistic patterns
    // Peak hours: 9-11 AM, 2-4 PM, 7-9 PM
    final peakHours = [9, 10, 14, 15, 19, 20];
    final normalHours = [8, 11, 12, 13, 16, 17, 18, 21, 22];
    final lowHours = [0, 1, 2, 3, 4, 5, 6, 7, 23];
    
    var remainingMinutes = totalMinutes;
    
    // Distribute 50% to peak hours
    for (final hour in peakHours) {
      final minutes = (remainingMinutes * 0.5 / peakHours.length).round();
      hourlyUsage[hour] = Duration(minutes: minutes);
      remainingMinutes -= minutes;
    }
    
    // Distribute 35% to normal hours
    for (final hour in normalHours) {
      final minutes = (remainingMinutes * 0.35 / normalHours.length).round();
      hourlyUsage[hour] = Duration(minutes: minutes);
      remainingMinutes -= minutes;
    }
    
    // Distribute remaining to low hours
    for (final hour in lowHours) {
      final minutes = (remainingMinutes / lowHours.length).round();
      hourlyUsage[hour] = Duration(minutes: minutes);
    }
    
    return hourlyUsage;
  }

  bool _shouldResetDaily(DateTime lastUsed, DateTime now) {
    return lastUsed.day != now.day || 
           lastUsed.month != now.month || 
           lastUsed.year != now.year;
  }

  bool _shouldResetWeekly(DateTime lastUsed, DateTime now) {
    final lastWeekStart = lastUsed.subtract(Duration(days: lastUsed.weekday - 1));
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return lastWeekStart.difference(currentWeekStart).inDays.abs() >= 7;
  }

  bool _shouldResetMonthly(DateTime lastUsed, DateTime now) {
    return lastUsed.month != now.month || lastUsed.year != now.year;
  }

  /// Gets usage statistics for multiple app groups
  Future<Map<String, AggregatedUsageStats>> getMultipleGroupsUsageStatistics(
    List<String> groupIds,
    TimePeriod period,
  ) async {
    final results = <String, AggregatedUsageStats>{};
    
    for (final groupId in groupIds) {
      results[groupId] = await getGroupUsageStatistics(groupId, period);
    }
    
    return results;
  }

  /// Calculates usage percentage for each app within a time period
  Future<Map<String, double>> getUsagePercentages(TimePeriod period) async {
    final stats = await getUsageStatistics(period);
    final totalMinutes = stats.totalUsage.inMinutes;
    
    if (totalMinutes == 0) {
      return {};
    }
    
    final percentages = <String, double>{};
    for (final entry in stats.appUsage.entries) {
      final appMinutes = entry.value.inMinutes;
      percentages[entry.key] = (appMinutes / totalMinutes) * 100;
    }
    
    return percentages;
  }

  /// Gets usage statistics for a specific date range
  Future<AggregatedUsageStats> getUsageStatisticsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allStats = await _databaseHelper.getAllUsageStats();
    final appGroups = await _databaseHelper.getAllAppGroups();
    
    // Create a map of app package to group ID for quick lookup
    final appToGroupMap = <String, String>{};
    for (final group in appGroups) {
      for (final appPackage in group.appPackages) {
        appToGroupMap[appPackage] = group.id;
      }
    }
    
    // Filter stats based on the date range
    Duration totalUsage = Duration.zero;
    final appUsage = <String, Duration>{};
    final groupUsage = <String, Duration>{};
    
    for (final stat in allStats) {
      // Check if the last used date falls within the range
      if (stat.lastUsed.isAfter(startDate) && stat.lastUsed.isBefore(endDate)) {
        // For simplicity, use daily usage as the period usage
        // In a real implementation, you'd need more granular tracking
        final periodUsage = stat.dailyUsage;
        
        if (periodUsage > Duration.zero) {
          totalUsage += periodUsage;
          appUsage[stat.appPackage] = periodUsage;
          
          // Aggregate by group if app belongs to a group
          final groupId = stat.groupId ?? appToGroupMap[stat.appPackage];
          if (groupId != null) {
            groupUsage[groupId] = (groupUsage[groupId] ?? Duration.zero) + periodUsage;
          }
        }
      }
    }
    
    return AggregatedUsageStats(
      totalUsage: totalUsage,
      appUsage: appUsage,
      groupUsage: groupUsage,
      periodStart: startDate,
      periodEnd: endDate,
      period: TimePeriod.daily, // Custom range defaults to daily
    );
  }

  /// Checks if usage data needs to be reset based on time periods
  Future<void> performPeriodicReset() async {
    final now = DateTime.now();
    final allStats = await _databaseHelper.getAllUsageStats();
    
    for (final stat in allStats) {
      bool needsUpdate = false;
      var updatedStats = stat;
      
      // Reset daily stats if it's a new day
      if (_shouldResetDaily(stat.lastUsed, now)) {
        updatedStats = updatedStats.copyWith(dailyUsage: Duration.zero);
        needsUpdate = true;
      }
      
      // Reset weekly stats if it's a new week
      if (_shouldResetWeekly(stat.lastUsed, now)) {
        updatedStats = updatedStats.copyWith(weeklyUsage: Duration.zero);
        needsUpdate = true;
      }
      
      // Reset monthly stats if it's a new month
      if (_shouldResetMonthly(stat.lastUsed, now)) {
        updatedStats = updatedStats.copyWith(monthlyUsage: Duration.zero);
        needsUpdate = true;
      }
      
      if (needsUpdate) {
        await _databaseHelper.insertOrUpdateUsageStats(updatedStats);
      }
    }
  }

  /// Gets summary statistics for dashboard display
  Future<Map<String, dynamic>> getSummaryStatistics(TimePeriod period) async {
    final stats = await getUsageStatistics(period);
    final trends = await getUsageTrends(period);
    
    return {
      'totalUsage': stats.totalUsage,
      'totalApps': stats.appUsage.length,
      'totalGroups': stats.groupUsage.length,
      'averageSessionLength': trends.averageSessionLength,
      'changePercentage': trends.changePercentage,
      'isIncreasing': trends.isIncreasing,
      'mostUsedApp': trends.mostUsedApps.isNotEmpty ? trends.mostUsedApps.first : null,
      'mostUsedGroup': trends.mostUsedGroups.isNotEmpty ? trends.mostUsedGroups.first : null,
    };
  }
}