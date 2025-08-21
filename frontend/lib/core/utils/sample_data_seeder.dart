import '../models/models.dart';
import '../services/usage_stats_service.dart';
import '../../shared/database/database_helper.dart';

/// Utility class to seed the database with sample data for testing and demo purposes
class SampleDataSeeder {
  final DatabaseHelper _databaseHelper;
  final UsageStatsService _usageStatsService;

  SampleDataSeeder({
    required DatabaseHelper databaseHelper,
    required UsageStatsService usageStatsService,
  })  : _databaseHelper = databaseHelper,
        _usageStatsService = usageStatsService;

  /// Seeds the database with sample app groups and usage statistics
  Future<void> seedSampleData() async {
    try {
      // Check if data already exists
      final existingGroups = await _databaseHelper.getAllAppGroups();
      final existingStats = await _databaseHelper.getAllUsageStats();
      
      if (existingGroups.isNotEmpty || existingStats.isNotEmpty) {
        // Data already exists, skip seeding
        return;
      }

      // Create sample app groups
      await _createSampleAppGroups();
      
      // Create sample usage statistics
      await _createSampleUsageStats();
      
      print('Sample data seeded successfully!');
    } catch (e) {
      print('Error seeding sample data: $e');
    }
  }

  Future<void> _createSampleAppGroups() async {
    final now = DateTime.now();
    
    final sampleGroups = [
      AppGroup(
        id: 'social_media',
        name: 'Social Media',
        appPackages: [
          'com.instagram.android',
          'com.facebook.katana',
          'com.twitter.android',
          'com.snapchat.android',
        ],
        timeLimit: const Duration(hours: 2),
        createdAt: now.subtract(const Duration(days: 30)),
        isActive: true,
      ),
      AppGroup(
        id: 'entertainment',
        name: 'Entertainment',
        appPackages: [
          'com.netflix.mediaclient',
          'com.google.android.youtube',
          'com.spotify.music',
          'com.disney.disneyplus',
        ],
        timeLimit: const Duration(hours: 3),
        createdAt: now.subtract(const Duration(days: 25)),
        isActive: true,
      ),
      AppGroup(
        id: 'productivity',
        name: 'Productivity',
        appPackages: [
          'com.microsoft.office.outlook',
          'com.google.android.apps.docs',
          'com.slack',
          'com.notion.id',
        ],
        timeLimit: const Duration(hours: 8),
        createdAt: now.subtract(const Duration(days: 20)),
        isActive: true,
      ),
      AppGroup(
        id: 'games',
        name: 'Games',
        appPackages: [
          'com.supercell.clashofclans',
          'com.king.candycrushsaga',
          'com.mojang.minecraftpe',
          'com.roblox.client',
        ],
        timeLimit: const Duration(hours: 1),
        createdAt: now.subtract(const Duration(days: 15)),
        isActive: true,
      ),
    ];

    for (final group in sampleGroups) {
      await _databaseHelper.insertAppGroup(group);
    }
  }

  Future<void> _createSampleUsageStats() async {
    final now = DateTime.now();
    
    // Sample usage data for different apps
    final sampleUsageData = [
      // Social Media Apps
      {
        'package': 'com.instagram.android',
        'group': 'social_media',
        'daily': const Duration(hours: 1, minutes: 30),
        'weekly': const Duration(hours: 8, minutes: 45),
        'monthly': const Duration(hours: 32, minutes: 20),
      },
      {
        'package': 'com.facebook.katana',
        'group': 'social_media',
        'daily': const Duration(minutes: 45),
        'weekly': const Duration(hours: 4, minutes: 20),
        'monthly': const Duration(hours: 18, minutes: 30),
      },
      {
        'package': 'com.twitter.android',
        'group': 'social_media',
        'daily': const Duration(minutes: 25),
        'weekly': const Duration(hours: 2, minutes: 15),
        'monthly': const Duration(hours: 9, minutes: 45),
      },
      
      // Entertainment Apps
      {
        'package': 'com.netflix.mediaclient',
        'group': 'entertainment',
        'daily': const Duration(hours: 2, minutes: 15),
        'weekly': const Duration(hours: 12, minutes: 30),
        'monthly': const Duration(hours: 48, minutes: 45),
      },
      {
        'package': 'com.google.android.youtube',
        'group': 'entertainment',
        'daily': const Duration(hours: 1, minutes: 45),
        'weekly': const Duration(hours: 9, minutes: 20),
        'monthly': const Duration(hours: 38, minutes: 15),
      },
      {
        'package': 'com.spotify.music',
        'group': 'entertainment',
        'daily': const Duration(hours: 3, minutes: 20),
        'weekly': const Duration(hours: 18, minutes: 45),
        'monthly': const Duration(hours: 72, minutes: 30),
      },
      
      // Productivity Apps
      {
        'package': 'com.microsoft.office.outlook',
        'group': 'productivity',
        'daily': const Duration(hours: 2, minutes: 30),
        'weekly': const Duration(hours: 15, minutes: 20),
        'monthly': const Duration(hours: 58, minutes: 45),
      },
      {
        'package': 'com.google.android.apps.docs',
        'group': 'productivity',
        'daily': const Duration(hours: 1, minutes: 15),
        'weekly': const Duration(hours: 7, minutes: 30),
        'monthly': const Duration(hours: 28, minutes: 20),
      },
      {
        'package': 'com.slack',
        'group': 'productivity',
        'daily': const Duration(minutes: 45),
        'weekly': const Duration(hours: 4, minutes: 15),
        'monthly': const Duration(hours: 16, minutes: 30),
      },
      
      // Games
      {
        'package': 'com.supercell.clashofclans',
        'group': 'games',
        'daily': const Duration(minutes: 35),
        'weekly': const Duration(hours: 3, minutes: 20),
        'monthly': const Duration(hours: 12, minutes: 45),
      },
      {
        'package': 'com.king.candycrushsaga',
        'group': 'games',
        'daily': const Duration(minutes: 20),
        'weekly': const Duration(hours: 1, minutes: 45),
        'monthly': const Duration(hours: 6, minutes: 30),
      },
    ];

    for (final data in sampleUsageData) {
      final usageStats = UsageStats(
        appPackage: data['package'] as String,
        groupId: data['group'] as String,
        dailyUsage: data['daily'] as Duration,
        weeklyUsage: data['weekly'] as Duration,
        monthlyUsage: data['monthly'] as Duration,
        lastUsed: now.subtract(Duration(minutes: (data['daily'] as Duration).inMinutes ~/ 10)),
      );
      
      await _databaseHelper.insertOrUpdateUsageStats(usageStats);
    }
  }

  /// Clears all sample data from the database
  Future<void> clearSampleData() async {
    try {
      // Clear usage stats
      final allStats = await _databaseHelper.getAllUsageStats();
      for (final stat in allStats) {
        await _databaseHelper.deleteUsageStats(stat.appPackage);
      }
      
      // Clear app groups
      final allGroups = await _databaseHelper.getAllAppGroups();
      for (final group in allGroups) {
        await _databaseHelper.deleteAppGroup(group.id);
      }
      
      print('Sample data cleared successfully!');
    } catch (e) {
      print('Error clearing sample data: $e');
    }
  }
}