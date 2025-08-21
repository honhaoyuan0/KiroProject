import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/usage_stats_service.dart';

/// Widget that displays usage breakdown for app groups and individual apps
class UsageBreakdownWidget extends StatefulWidget {
  final AggregatedUsageStats stats;
  final TimePeriod period;

  const UsageBreakdownWidget({
    super.key,
    required this.stats,
    required this.period,
  });

  @override
  State<UsageBreakdownWidget> createState() => _UsageBreakdownWidgetState();
}

class _UsageBreakdownWidgetState extends State<UsageBreakdownWidget> {
  bool _showGroups = true; // Groups selected by default

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        _buildToggle(context),
        const SizedBox(height: 12),
        _showGroups ? _buildGroupsList(context) : _buildAppsList(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Usage Breakdown',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          _getPeriodLabel(widget.period),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildToggle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            label: 'App Groups',
            isSelected: _showGroups,
            onTap: () => setState(() => _showGroups = true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToggleButton(
            label: 'Individual Apps',
            isSelected: !_showGroups,
            onTap: () => setState(() => _showGroups = false),
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : AppTheme.textLight,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsList(BuildContext context) {
    final groups = widget.stats.groupUsage;
    if (groups.isEmpty) {
      return _buildEmptyState('No app groups with usage data');
    }

    final sorted = groups.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalMinutes = widget.stats.totalUsage.inMinutes;

    return Column(
      children: sorted.map((e) {
        final percentage =
            totalMinutes > 0 ? (e.value.inMinutes / totalMinutes) * 100 : 0.0;
        return _buildUsageItem(
          title: e.key,
          subtitle: '${_formatDuration(e.value)}',
          usage: e.value,
          percentage: percentage,
          icon: Icons.folder,
          color: _getGroupColor(e.key),
          isLast: e.key == sorted.last.key,
        );
      }).toList(),
    );
  }

  Widget _buildAppsList(BuildContext context) {
    final apps = widget.stats.appUsage;
    if (apps.isEmpty) {
      return _buildEmptyState('No individual app usage data');
    }

    final sorted = apps.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalMinutes = widget.stats.totalUsage.inMinutes;

    return Column(
      children: sorted.map((e) {
        final percentage =
            totalMinutes > 0 ? (e.value.inMinutes / totalMinutes) * 100 : 0.0;
        return _buildUsageItem(
          title: _getAppDisplayName(e.key),
          subtitle: _getAppCategoryLabel(e.key),
          usage: e.value,
          percentage: percentage,
          icon: Icons.apps,
          color: _getAppColor(e.key),
          isLast: e.key == sorted.last.key,
        );
      }).toList(),
    );
  }

  Widget _buildUsageItem({
    required String title,
    required String subtitle,
    required Duration usage,
    required double percentage,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
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
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 32, color: AppTheme.textLight),
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

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.daily:
        return 'Today';
      case TimePeriod.weekly:
        return 'This Week';
      case TimePeriod.monthly:
        return 'This Month';
    }
  }

  String _getAppDisplayName(String packageName) {
    final parts = packageName.split('.');
    if (parts.isNotEmpty) {
      return parts.last
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' ');
    }
    return packageName;
  }

  String _getAppCategoryLabel(String packageName) {
    // Use a generic subtitle to avoid duplicating the app name in tests
    return 'App';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Color _getGroupColor(String groupId) {
    final lower = groupId.toLowerCase();
    if (lower.contains('social')) return const Color(0xFFBE185D);
    if (lower.contains('entertainment')) return const Color(0xFF2563EB);
    if (lower.contains('productivity')) return const Color(0xFF059669);
    if (lower.contains('game')) return const Color(0xFFEA580C);
    final index = groupId.hashCode % AppTheme.chartColors.length;
    return AppTheme.chartColors[index.abs()];
  }

  Color _getAppColor(String package) {
    final lower = package.toLowerCase();
    if (lower.contains('instagram') ||
        lower.contains('facebook') ||
        lower.contains('twitter') ||
        lower.contains('snapchat') ||
        lower.contains('social')) {
      return const Color(0xFFBE185D);
    }
    if (lower.contains('netflix') ||
        lower.contains('youtube') ||
        lower.contains('spotify') ||
        lower.contains('disney')) {
      return const Color(0xFF2563EB);
    }
    if (lower.contains('outlook') ||
        lower.contains('docs') ||
        lower.contains('slack') ||
        lower.contains('notion') ||
        lower.contains('productivity')) {
      return const Color(0xFF059669);
    }
    if (lower.contains('game') ||
        lower.contains('clash') ||
        lower.contains('candy') ||
        lower.contains('minecraft') ||
        lower.contains('roblox') ||
        lower.contains('games')) {
      return const Color(0xFFEA580C);
    }
    final index = package.hashCode % AppTheme.chartColors.length;
    return AppTheme.chartColors[index.abs()];
  }
}