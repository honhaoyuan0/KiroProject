/// Application-wide constants for WiseScreen
class AppConstants {
  // App Information
  static const String appName = 'WiseScreen';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'wise_screen.db';
  static const int databaseVersion = 1;
  
  // API Configuration
  static const String baseUrl = 'https://api.wisescreen.com';
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Usage Tracking
  static const Duration trackingInterval = Duration(minutes: 1);
  static const Duration dailyResetTime = Duration(hours: 24);
  
  // Overlay System
  static const Duration overlayDisplayDuration = Duration(seconds: 5);
  static const double overlayOpacity = 0.9;
  
  // AI Insights
  static const int minDataPointsForInsights = 7; // 7 days
  static const Duration insightsUpdateInterval = Duration(hours: 6);
  
  // Notifications
  static const String notificationChannelId = 'wise_screen_notifications';
  static const String notificationChannelName = 'WiseScreen Notifications';
  
  // Permissions
  static const List<String> requiredPermissions = [
    'android.permission.PACKAGE_USAGE_STATS',
    'android.permission.SYSTEM_ALERT_WINDOW',
    'android.permission.POST_NOTIFICATIONS',
  ];
}