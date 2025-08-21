import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/usage_stats_service.dart';

/// Widget that displays usage statistics in various chart formats
class UsageChartWidget extends StatefulWidget {
  final AggregatedUsageStats stats;
  final UsageTrends trends;
  final TimePeriod period;

  const UsageChartWidget({
    super.key,
    required this.stats,
    required this.trends,
    required this.period,
  });

  @override
  State<UsageChartWidget> createState() => _UsageChartWidgetState();
}

class _UsageChartWidgetState extends State<UsageChartWidget> {
  int _selectedChartType = 0; // 0: Bar Chart, 1: Line Chart

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // ✅ Key fix: prevent unbounded height
      children: [
        // Chart type selector
        _buildChartTypeSelector(),
        const SizedBox(height: 16),
        
        // Chart display - use SizedBox with fixed height instead of Flexible
        SizedBox(
          height: 300, // ✅ Fixed height prevents layout conflicts
          child: _buildSelectedChart(),
        ),
      ],
    );
  }

  Widget _buildChartTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildChartTypeButton(
          index: 0,
          icon: Icons.bar_chart,
          label: 'Bar',
        ),
        _buildChartTypeButton(
          index: 1,
          icon: Icons.show_chart,
          label: 'Trend',
        ),
      ],
    );
  }

  Widget _buildChartTypeButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedChartType == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : AppTheme.textLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedChartType) {
      case 0:
        return _buildBarChart();
      case 1:
        return _buildLineChart();
      default:
        return _buildBarChart();
    }
  }

  Widget _buildBarChart() {
    if (widget.stats.appUsage.isEmpty) {
      return _buildNoDataWidget();
    }

    // Get top 10 apps for bar chart
    final sortedApps = widget.stats.appUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topApps = sortedApps.take(10).toList();
    
    final maxHours = topApps.first.value.inMinutes / 60.0;
    final yStep = _calculateYAxisStep(maxHours);
    final niceMaxY = _calculateNiceMaxY(maxHours);
    
    // Calculate total width needed: each bar needs more space for better labels
    final barWidth = 90.0; // Give labels more space
    final totalWidth = topApps.length * barWidth;
    final minWidth = MediaQuery.of(context).size.width - 80; // Account for left axis
    final chartWidth = totalWidth > minWidth ? totalWidth : minWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: constraints.maxHeight, // Use available height
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: niceMaxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    //tooltipBackgroundColor: AppTheme.primaryPurple.withOpacity(0.9),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final appName = _getAppDisplayName(topApps[group.x.toInt()].key);
                      final hours = rod.toY;
                      return BarTooltipItem(
                        '$appName\n${_formatDurationInHours(hours)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= topApps.length) return const Text('');
                        final appName = _getAppDisplayName(topApps[value.toInt()].key);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: barWidth - 10, // Constrain width to prevent overflow
                            child: Text(
                              appName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3, // Allow longer names to wrap
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                      reservedSize: 50, // Reduced since we removed rotation
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatHoursTick(value, yStep),
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                      reservedSize: 45,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: topApps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final appEntry = entry.value;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: appEntry.value.inMinutes / 60.0,
                        color: AppTheme.chartColors[index % AppTheme.chartColors.length],
                        width: 25, // Slightly increased bar width
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yStep,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textLight.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLineChart() {
    // For line chart, we'll show hourly usage pattern
    final hourlyUsage = widget.trends.hourlyUsage;
    
    if (hourlyUsage.isEmpty) {
      return _buildNoDataWidget();
    }

    final maxHours = hourlyUsage.values
        .map((duration) => duration.inMinutes / 60.0)
        .reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxHours / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.textLight.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (value, meta) {
                final hour = value.toInt();
                if (hour < 0 || hour > 23) return const Text('');
                return Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}hr', // Changed from 'm' to 'hr'
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
              reservedSize: 45, // Increased to accommodate 'hr' unit
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 23,
        minY: 0,
        maxY: maxHours * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(24, (hour) {
              final usage = hourlyUsage[hour] ?? Duration.zero;
              return FlSpot(hour.toDouble(), usage.inMinutes / 60.0); // Convert to hours
            }),
            isCurved: true,
            color: AppTheme.primaryPurple,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryPurple,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryPurple.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final hour = spot.x.toInt();
                final hours = spot.y;
                return LineTooltipItem(
                  '${hour.toString().padLeft(2, '0')}:00\n${_formatDurationInHours(hours)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No usage data available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start using apps to see your usage patterns',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
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
    } else {
      return '${minutes}m';
    }
  }

  // New helper method to format hours as decimal
  String _formatDurationInHours(double hours) {
    if (hours >= 1) {
      return '${hours.toStringAsFixed(1)}hr';
    } else {
      final minutes = (hours * 60).round();
      return '${minutes}min';
    }
  }

  // Calculate a pleasant Y-axis step based on the max value
  double _calculateYAxisStep(double maxHours) {
    if (maxHours <= 2) return 0.25; // 15 minutes
    if (maxHours <= 6) return 0.5;  // 30 minutes
    if (maxHours <= 12) return 1.0; // 1 hour
    return 2.0;                     // 2 hours
  }

  // Round up to the next multiple of the step
  double _calculateNiceMaxY(double maxHours) {
    final step = _calculateYAxisStep(maxHours);
    return ((maxHours / step).ceil()) * step;
  }

  // Format Y-axis tick label based on the chosen step
  String _formatHoursTick(double value, double step) {
    if (step < 1.0) {
      return '${value.toStringAsFixed(1)}hr';
    }
    return '${value.toStringAsFixed(0)}hr';
  }
}