import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/services/usage_stats_service.dart';
import 'core/utils/sample_data_seeder.dart';
import 'shared/database/database_helper.dart';
import 'features/analysis/screen_insights_page.dart';

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
    WiseScreenApp(
      databaseHelper: databaseHelper,
      usageStatsService: usageStatsService,
    ),
  );
}

class WiseScreenApp extends StatelessWidget {
  final DatabaseHelper databaseHelper;
  final UsageStatsService usageStatsService;

  const WiseScreenApp({
    super.key,
    required this.databaseHelper,
    required this.usageStatsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseHelper>.value(value: databaseHelper),
        Provider<UsageStatsService>.value(value: usageStatsService),
      ],
      child: MaterialApp(
        title: 'WiseScreen',
        theme: AppTheme.lightTheme,
        home: const WiseScreenHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class WiseScreenHomePage extends StatefulWidget {
  const WiseScreenHomePage({super.key});

  @override
  State<WiseScreenHomePage> createState() => _WiseScreenHomePageState();
}

class _WiseScreenHomePageState extends State<WiseScreenHomePage> {
  int _selectedIndex = 0;

  // For now, we'll just show the Screen Insights page
  // Later, you can add more pages like Timer, Settings, etc.
  final List<Widget> _pages = [
    const ScreenInsightsPage(),
    const PlaceholderPage(title: 'Timer'),
    const PlaceholderPage(title: 'Settings'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Insights',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Placeholder page for features not yet implemented
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title == 'Timer' ? Icons.timer : Icons.settings,
              size: 64,
              color: AppTheme.primaryPurple.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '$title Feature',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to insights
                if (context
                        .findAncestorStateOfType<_WiseScreenHomePageState>() !=
                    null) {
                  context
                      .findAncestorStateOfType<_WiseScreenHomePageState>()!
                      ._onItemTapped(0);
                }
              },
              child: const Text('View Insights'),
            ),
          ],
        ),
      ),
    );
  }
}
