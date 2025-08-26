import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/services/usage_stats_service.dart';
import 'core/utils/sample_data_seeder.dart';
import 'core/providers/app_providers.dart';
import 'core/routing/app_router.dart';
import 'shared/database/database_helper.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final databaseHelper = DatabaseHelper();
  await databaseHelper.database; // Initialize the database

  // Initialize usage stats service
  final usageStatsService = UsageStatsService(databaseHelper: databaseHelper);

  // Seed sample data for demo purposes
  final dataSeeder = SampleDataSeeder(
    databaseHelper: databaseHelper,
    usageStatsService: usageStatsService,
  );
  await dataSeeder.seedSampleData();

  runApp(
    ProviderScope(
      overrides: [
        databaseHelperProvider.overrideWithValue(databaseHelper),
      ],
      child: const WiseScreenApp(),
    ),
  );
}

class WiseScreenApp extends StatelessWidget {
  const WiseScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiseScreen',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
