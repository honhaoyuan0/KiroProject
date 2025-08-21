import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/services/usage_stats_service.dart';
import '../../core/models/models.dart';
import 'widgets/usage_chart_widget.dart';
// Usage breakdown functionality is now integrated into summary_stats_widget.dart
import 'widgets/ai_insights_card.dart';
import 'widgets/summary_stats_widget.dart';

/// Main screen insights page with tab navigation for different time periods
class ScreenInsightsPage extends StatefulWidget {
  const ScreenInsightsPage({super.key});

  @override
  State<ScreenInsightsPage> createState() => _ScreenInsightsPageState();
}

class _ScreenInsightsPageState extends State<ScreenInsightsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UsageStatsService _usageStatsService;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Data for different time periods
  AggregatedUsageStats? _dailyStats;
  AggregatedUsageStats? _weeklyStats;
  AggregatedUsageStats? _monthlyStats;
  
  UsageTrends? _dailyTrends;
  UsageTrends? _weeklyTrends;
  UsageTrends? _monthlyTrends;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _usageStatsService = context.read<UsageStatsService>();
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Loads usage statistics and trends for all time periods
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load statistics for all periods
      final futures = await Future.wait([
        _usageStatsService.getUsageStatistics(TimePeriod.daily),
        _usageStatsService.getUsageStatistics(TimePeriod.weekly),
        _usageStatsService.getUsageStatistics(TimePeriod.monthly),
        _usageStatsService.getUsageTrends(TimePeriod.daily),
        _usageStatsService.getUsageTrends(TimePeriod.weekly),
        _usageStatsService.getUsageTrends(TimePeriod.monthly),
      ]);

      setState(() {
        _dailyStats = futures[0] as AggregatedUsageStats;
        _weeklyStats = futures[1] as AggregatedUsageStats;
        _monthlyStats = futures[2] as AggregatedUsageStats;
        _dailyTrends = futures[3] as UsageTrends;
        _weeklyTrends = futures[4] as UsageTrends;
        _monthlyTrends = futures[5] as UsageTrends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load usage data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Refreshes data for the current tab
  Future<void> _refreshData() async {
    await _loadAllData();
  }

  /// Gets the current period based on selected tab
  TimePeriod get _currentPeriod {
    switch (_tabController.index) {
      case 0:
        return TimePeriod.daily;
      case 1:
        return TimePeriod.weekly;
      case 2:
        return TimePeriod.monthly;
      default:
        return TimePeriod.daily;
    }
  }

  /// Gets the current stats based on selected tab
  AggregatedUsageStats? get _currentStats {
    switch (_tabController.index) {
      case 0:
        return _dailyStats;
      case 1:
        return _weeklyStats;
      case 2:
        return _monthlyStats;
      default:
        return _dailyStats;
    }
  }

  /// Gets the current trends based on selected tab
  UsageTrends? get _currentTrends {
    switch (_tabController.index) {
      case 0:
        return _dailyTrends;
      case 1:
        return _weeklyTrends;
      case 2:
        return _monthlyTrends;
      default:
        return _dailyTrends;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.today),
              text: 'Daily',
            ),
            Tab(
              icon: Icon(Icons.view_week),
              text: 'Weekly',
            ),
            Tab(
              icon: Icon(Icons.calendar_month),
              text: 'Monthly',
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading usage insights...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildInsightsView(TimePeriod.daily),
        _buildInsightsView(TimePeriod.weekly),
        _buildInsightsView(TimePeriod.monthly),
      ],
    );
  }

  Widget _buildInsightsView(TimePeriod period) {
    final stats = _currentStats;
    final trends = _currentTrends;

    if (stats == null || trends == null) {
      return const Center(
        child: Text('No data available for this period'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Statistics (with integrated usage breakdown)
            SummaryStatsWidget(
              stats: stats,
              trends: trends,
              period: period,
            ),
            const SizedBox(height: 16),

            // Usage Overview Charts (moved above AI Insights for better UX flow)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usage Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    UsageChartWidget(
                      stats: stats,
                      trends: trends,
                      period: period,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI Insights Card (moved below charts for better information flow)
            AIInsightsCard(
              stats: stats,
              trends: trends,
              period: period,
            ),
            const SizedBox(height: 16),

            // Usage breakdown is now integrated into the Summary Statistics widget above
            
            // Add some bottom padding for better scrolling
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}