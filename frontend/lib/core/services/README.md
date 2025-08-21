# Usage Statistics Service

The `UsageStatsService` provides comprehensive functionality for collecting, processing, and analyzing app usage statistics. It supports daily, weekly, and monthly aggregations with trend analysis and pattern detection.

## Features

- **Multi-period Statistics**: Daily, weekly, and monthly usage tracking
- **App Group Support**: Aggregate statistics by app groups
- **Trend Analysis**: Calculate usage trends and patterns
- **Data Processing**: Automatic period resets and data aggregation
- **Flexible Queries**: Top apps, usage percentages, date ranges

## Usage Examples

### Basic Usage Statistics

```dart
final usageStatsService = UsageStatsService();

// Get daily usage statistics
final dailyStats = await usageStatsService.getUsageStatistics(TimePeriod.daily);
print('Total daily usage: ${dailyStats.totalUsage.inMinutes} minutes');
print('Apps used: ${dailyStats.appUsage.length}');

// Get weekly usage statistics
final weeklyStats = await usageStatsService.getUsageStatistics(TimePeriod.weekly);
print('Total weekly usage: ${weeklyStats.totalUsage.inHours} hours');
```

### Usage Trends and Patterns

```dart
// Get usage trends for analysis
final trends = await usageStatsService.getUsageTrends(TimePeriod.daily);
print('Usage change: ${trends.changePercentage.toStringAsFixed(1)}%');
print('Most used apps: ${trends.mostUsedApps.take(3).join(', ')}');
print('Average session: ${trends.averageSessionLength.inMinutes} minutes');
```

### App Group Statistics

```dart
// Get statistics for a specific app group
final groupStats = await usageStatsService.getGroupUsageStatistics(
  'social_media_group',
  TimePeriod.daily,
);
print('Group usage: ${groupStats.totalUsage.inMinutes} minutes');

// Get statistics for multiple groups
final multipleGroups = await usageStatsService.getMultipleGroupsUsageStatistics(
  ['social_media', 'productivity', 'games'],
  TimePeriod.weekly,
);
```

### Top Apps and Usage Percentages

```dart
// Get top 5 most used apps
final topApps = await usageStatsService.getTopApps(TimePeriod.daily, limit: 5);
for (final app in topApps) {
  print('${app.key}: ${app.value.inMinutes} minutes');
}

// Get usage percentages
final percentages = await usageStatsService.getUsagePercentages(TimePeriod.daily);
percentages.forEach((app, percentage) {
  print('$app: ${percentage.toStringAsFixed(1)}%');
});
```

### Updating Usage Data

```dart
// Update usage for an app
await usageStatsService.updateAppUsage(
  'com.example.myapp',
  Duration(minutes: 15),
  'productivity_group',
);

// Perform periodic reset (call this daily/weekly/monthly)
await usageStatsService.performPeriodicReset();
```

### Summary Statistics for Dashboard

```dart
// Get comprehensive summary for dashboard display
final summary = await usageStatsService.getSummaryStatistics(TimePeriod.daily);
print('Total usage: ${summary['totalUsage']}');
print('Apps used: ${summary['totalApps']}');
print('Most used app: ${summary['mostUsedApp']}');
print('Usage trend: ${summary['isIncreasing'] ? 'Increasing' : 'Decreasing'}');
```

## Data Models

### AggregatedUsageStats
Contains aggregated usage data for a specific time period:
- `totalUsage`: Total usage duration
- `appUsage`: Map of app package to usage duration
- `groupUsage`: Map of group ID to usage duration
- `periodStart/End`: Time period boundaries
- `period`: The time period type

### UsageTrends
Contains trend analysis and patterns:
- `changePercentage`: Usage change from previous period
- `isIncreasing`: Whether usage is trending up
- `averageSessionLength`: Average session duration
- `mostUsedApps/Groups`: Lists of most used items
- `hourlyUsage`: Usage distribution by hour of day

## Time Periods

The service supports three time periods:
- `TimePeriod.daily`: Current day statistics
- `TimePeriod.weekly`: Current week statistics  
- `TimePeriod.monthly`: Current month statistics

## Integration with Database

The service integrates with `DatabaseHelper` to:
- Store and retrieve usage statistics
- Manage app group relationships
- Handle data persistence and updates
- Support transactional operations

## Testing

Comprehensive unit tests are provided in `usage_stats_service_test.dart` covering:
- All public methods and edge cases
- Mock database interactions
- Data aggregation accuracy
- Trend calculation correctness
- Error handling scenarios

Run tests with:
```bash
flutter test test/core/services/usage_stats_service_test.dart
```