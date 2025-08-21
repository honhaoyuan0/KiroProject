import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/usage_stats_service.dart';
import '../../../shared/database/database_helper.dart';
import '../../../core/models/models.dart';

/// Widget that displays summary statistics for the selected time period
class SummaryStatsWidget extends StatefulWidget {
  final AggregatedUsageStats stats;
  final UsageTrends trends;
  final TimePeriod period;

  const SummaryStatsWidget({
    super.key,
    required this.stats,
    required this.trends,
    required this.period,
  });

  @override
  State<SummaryStatsWidget> createState() => _SummaryStatsWidgetState();
}

class _SummaryStatsWidgetState extends State<SummaryStatsWidget> {
  bool _showApps = true; // true for apps, false for groups
  bool _isExpanded = false;
  List<AppGroup> _appGroups = [];
  bool _isLoadingGroups = false;

  @override
  void initState() {
    super.initState();
    _loadAppGroups();
  }

  Future<void> _loadAppGroups() async {
    setState(() => _isLoadingGroups = true);
    
    try {
      final databaseHelper = DatabaseHelper();
      final groups = await databaseHelper.getAllAppGroups();
      setState(() {
        _appGroups = groups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      setState(() => _isLoadingGroups = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Total Usage',
                value: _formatDuration(widget.stats.totalUsage),
                subtitle: _getPeriodLabel(),
                icon: Icons.access_time,
                color: AppTheme.primaryPurple,
                trend: widget.trends.changePercentage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Apps Used',
                value: widget.stats.appUsage.length.toString(),
                subtitle: 'Different apps',
                icon: Icons.apps,
                color: AppTheme.accentPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Avg Session',
                value: _formatDuration(widget.trends.averageSessionLength),
                subtitle: 'Per session',
                icon: Icons.timer,
                color: AppTheme.lightPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Active Groups',
                value: widget.stats.groupUsage.length.toString(),
                subtitle: 'App groups',
                icon: Icons.folder,
                color: AppTheme.darkPurple,
              ),
            ),
          ],
        ),
        if (widget.stats.appUsage.isNotEmpty || widget.stats.groupUsage.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildUsageBreakdownSection(context),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    double? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              if (trend != null) _buildTrendIndicator(trend),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(double changePercentage) {
    final isPositive = changePercentage > 0;
    final isNeutral = changePercentage.abs() < 1;
    
    if (isNeutral) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.textLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove,
              size: 12,
              color: AppTheme.textLight,
            ),
            const SizedBox(width: 2),
            Text(
              '0%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    final color = isPositive ? AppTheme.errorColor : AppTheme.successColor;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${changePercentage.abs().toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBreakdownSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with toggle and expand/collapse
          _buildUsageBreakdownHeader(context),
          
          // Toggle buttons for Apps/Groups
          if (_isExpanded) ...[
            _buildToggleButtons(context),
            const SizedBox(height: 8),
          ],
          
          // Usage list (always show top 3, expand to show more)
          _buildUsageList(context),
        ],
      ),
    );
  }

  Widget _buildUsageBreakdownHeader(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.analytics,
              color: AppTheme.primaryPurple,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _isExpanded ? 'Usage Breakdown' : 'Top Apps',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (!_isExpanded) ...[
              Text(
                'View All',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.primaryPurple,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Individual Apps',
              isSelected: _showApps,
              onTap: () => setState(() => _showApps = true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton(
              label: 'App Groups',
              isSelected: !_showApps,
              onTap: () => setState(() => _showApps = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : AppTheme.textLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildUsageList(BuildContext context) {
    if (_showApps) {
      return _buildAppsList(context);
    } else {
      return _buildGroupsList(context);
    }
  }

  Widget _buildAppsList(BuildContext context) {
    if (widget.stats.appUsage.isEmpty) {
      return _buildEmptyState('No app usage data available');
    }

    // Sort apps by usage
    final sortedApps = widget.stats.appUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Show top 3 when collapsed, all when expanded
    final appsToShow = _isExpanded ? sortedApps : sortedApps.take(3).toList();
    final totalUsage = widget.stats.totalUsage.inMinutes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: appsToShow.map((entry) {
          final appPackage = entry.key;
          final usage = entry.value;
          final percentage = totalUsage > 0 ? (usage.inMinutes / totalUsage) * 100 : 0.0;
          final appName = _getAppDisplayName(appPackage);
          final groupName = _getAppGroupName(appPackage);

          return _buildUsageItem(
            title: appName,
            subtitle: groupName ?? 'No group',
            usage: usage,
            percentage: percentage,
            color: _getAppColor(appPackage),
            icon: Icons.apps,
            isLast: entry == appsToShow.last,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupsList(BuildContext context) {
    if (_isLoadingGroups) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.stats.groupUsage.isEmpty) {
      return _buildEmptyState('No app groups with usage data');
    }

    // Sort groups by usage
    final sortedGroups = widget.stats.groupUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Show top 3 when collapsed, all when expanded
    final groupsToShow = _isExpanded ? sortedGroups : sortedGroups.take(3).toList();
    final totalUsage = widget.stats.totalUsage.inMinutes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: groupsToShow.map((entry) {
          final groupId = entry.key;
          final usage = entry.value;
          final percentage = totalUsage > 0 ? (usage.inMinutes / totalUsage) * 100 : 0.0;
          
          // Find group details
          final group = _appGroups.firstWhere(
            (g) => g.id == groupId,
            orElse: () => AppGroup(
              id: groupId,
              name: 'Unknown Group',
              appPackages: [],
              timeLimit: const Duration(hours: 1),
              createdAt: DateTime.now(),
              isActive: false,
            ),
          );

          return _buildUsageItem(
            title: group.name,
            subtitle: '${group.appPackages.length} apps',
            usage: usage,
            percentage: percentage,
            color: _getGroupColor(groupId),
            icon: Icons.folder,
            isLast: entry == groupsToShow.last,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUsageItem({
    required String title,
    required String subtitle,
    required Duration usage,
    required double percentage,
    required Color color,
    required IconData icon,
    required bool isLast,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(usage),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 32,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  String _getPeriodLabel() {
    switch (widget.period) {
      case TimePeriod.daily:
        return 'Today';
      case TimePeriod.weekly:
        return 'This week';
      case TimePeriod.monthly:
        return 'This month';
    }
  }

  String? _getAppGroupName(String appPackage) {
    for (final group in _appGroups) {
      if (group.appPackages.contains(appPackage)) {
        return group.name;
      }
    }
    return null;
  }

  Color _getGroupColor(String groupId) {
    // Use meaningful colors for common group types
    final groupLower = groupId.toLowerCase();
    
    if (groupLower.contains('social')) {
      return const Color(0xFFBE185D); // Pink for social media
    } else if (groupLower.contains('entertainment')) {
      return const Color(0xFF2563EB); // Blue for entertainment
    } else if (groupLower.contains('productivity')) {
      return const Color(0xFF059669); // Green for productivity
    } else if (groupLower.contains('game')) {
      return const Color(0xFFEA580C); // Orange for games
    }
    
    // Fallback to vibrant chart colors
    final index = groupId.hashCode % AppTheme.chartColors.length;
    return AppTheme.chartColors[index.abs()];
  }

  Color _getAppColor(String appPackage) {
    // Use category-based colors for better visual grouping
    final packageLower = appPackage.toLowerCase();
    
    // Social Media - Purple/Pink tones
    if (packageLower.contains('instagram') || 
        packageLower.contains('facebook') || 
        packageLower.contains('twitter') ||
        packageLower.contains('snapchat')) {
      return const Color(0xFFBE185D); // Pink
    }
    
    // Entertainment - Blue/Cyan tones  
    if (packageLower.contains('netflix') || 
        packageLower.contains('youtube') || 
        packageLower.contains('spotify') ||
        packageLower.contains('disney')) {
      return const Color(0xFF2563EB); // Blue
    }
    
    // Productivity - Green tones
    if (packageLower.contains('outlook') || 
        packageLower.contains('docs') || 
        packageLower.contains('slack') ||
        packageLower.contains('notion')) {
      return const Color(0xFF059669); // Green
    }
    
    // Games - Orange/Red tones
    if (packageLower.contains('game') || 
        packageLower.contains('clash') || 
        packageLower.contains('candy') ||
        packageLower.contains('minecraft') ||
        packageLower.contains('roblox')) {
      return const Color(0xFFEA580C); // Orange
    }
    
    // Fallback to chart colors with better distribution
    final index = appPackage.hashCode % AppTheme.chartColors.length;
    return AppTheme.chartColors[index.abs()];
  }

  String _getAppDisplayName(String packageName) {
    // Extract app name from package name
    // In a real app, you'd have a mapping or use PackageManager
    final parts = packageName.split('.');
    if (parts.isNotEmpty) {
      return parts.last.replaceAll('_', ' ').split(' ')
          .map((word) => word.isNotEmpty ? 
              '${word[0].toUpperCase()}${word.substring(1)}' : '')
          .join(' ');
    }
    return packageName;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }
}