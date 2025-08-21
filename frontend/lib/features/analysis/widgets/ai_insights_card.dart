import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/usage_stats_service.dart';
import '../../../core/models/models.dart';
import '../../../core/network/network_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Widget that displays AI-generated insights and personalized advice
class AIInsightsCard extends StatefulWidget {
  final AggregatedUsageStats stats;
  final UsageTrends trends;
  final TimePeriod period;

  const AIInsightsCard({
    super.key,
    required this.stats,
    required this.trends,
    required this.period,
  });

  @override
  State<AIInsightsCard> createState() => _AIInsightsCardState();
}

class _AIInsightsCardState extends State<AIInsightsCard> {
  String? _aiInsight;
  bool _isLoadingInsight = false;
  String? _errorMessage;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadAIInsight();
  }

  @override
  void didUpdateWidget(AIInsightsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload insight if period or stats changed significantly
    if (oldWidget.period != widget.period ||
        oldWidget.stats.totalUsage != widget.stats.totalUsage) {
      _loadAIInsight();
    }
  }

  Future<void> _loadAIInsight() async {
    setState(() {
      _isLoadingInsight = true;
      _errorMessage = null;
    });

    try {
      final insight = await _generateAIInsight();
      setState(() {
        _aiInsight = insight;
        _isLoadingInsight = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingInsight = false;
        // Provide fallback insight
        _aiInsight = _getFallbackInsight();
      });
    }
  }

  Future<String> _generateAIInsight() async {
    // Check network connectivity
    final networkInfo = NetworkInfoFactory.instance;
    final isConnected = await networkInfo.isConnected;
    
    if (!isConnected) {
      return _getFallbackInsight();
    }

    // Build context for AI advice
    final context = _buildAdviceContext();
    
    try {
      // Make request to backend API
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/advice'), // Backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usage_duration': context.usageDuration.inMinutes,
          'time_of_day': context.timeOfDay,
          'app_categories': context.appCategories,
          'user_context': _buildUserContext(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['advice'] ?? _getFallbackInsight();
      } else {
        throw Exception('Backend API error: ${response.statusCode}');
      }
    } catch (e) {
      // Return fallback insight on any error
      return _getFallbackInsight();
    }
  }

  AdviceContext _buildAdviceContext() {
    final now = DateTime.now();
    String timeOfDay;
    
    if (now.hour < 6) {
      timeOfDay = 'night';
    } else if (now.hour < 12) {
      timeOfDay = 'morning';
    } else if (now.hour < 18) {
      timeOfDay = 'afternoon';
    } else {
      timeOfDay = 'evening';
    }

    // Extract app categories from most used apps
    final appCategories = widget.trends.mostUsedApps
        .map((app) => _categorizeApp(app))
        .toSet()
        .toList();

    return AdviceContext(
      usageDuration: widget.stats.totalUsage,
      timeOfDay: timeOfDay,
      appCategories: appCategories,
    );
  }

  String _buildUserContext() {
    final totalMinutes = widget.stats.totalUsage.inMinutes;
    final changePercentage = widget.trends.changePercentage;
    final periodName = widget.period.name;
    
    return 'User has spent $totalMinutes minutes on apps this $periodName. '
           'Usage has ${widget.trends.isIncreasing ? "increased" : "decreased"} '
           'by ${changePercentage.abs().toStringAsFixed(1)}% compared to the previous period. '
           'Most used apps: ${widget.trends.mostUsedApps.take(3).join(", ")}.';
  }

  String _getFallbackInsight() {
    final totalMinutes = widget.stats.totalUsage.inMinutes;
    final periodName = widget.period.name;
    
    if (totalMinutes == 0) {
      return "Great job! You haven't used any tracked apps ${_getPeriodText()}. "
             "Keep up the healthy digital habits!";
    }
    
    if (totalMinutes < 60) {
      return "Excellent screen time management ${_getPeriodText()}! "
             "You've kept your usage under an hour. "
             "Consider using this extra time for offline activities like reading or exercise.";
    } else if (totalMinutes < 180) {
      return "Your screen time ${_getPeriodText()} is moderate at ${_formatDuration(widget.stats.totalUsage)}. "
             "Try setting specific times for app usage to maintain this balance.";
    } else if (totalMinutes < 300) {
      return "You've spent ${_formatDuration(widget.stats.totalUsage)} on apps ${_getPeriodText()}. "
             "Consider taking regular breaks and setting app timers to reduce usage gradually.";
    } else {
      return "Your screen time ${_getPeriodText()} is quite high at ${_formatDuration(widget.stats.totalUsage)}. "
             "Try the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds. "
             "Consider setting stricter app limits.";
    }
  }

  String _getPeriodText() {
    switch (widget.period) {
      case TimePeriod.daily:
        return 'today';
      case TimePeriod.weekly:
        return 'this week';
      case TimePeriod.monthly:
        return 'this month';
    }
  }

  String _categorizeApp(String appPackage) {
    // Simple app categorization based on package name
    final packageLower = appPackage.toLowerCase();
    
    if (packageLower.contains('social') || 
        packageLower.contains('facebook') || 
        packageLower.contains('instagram') ||
        packageLower.contains('twitter') ||
        packageLower.contains('tiktok')) {
      return 'social';
    } else if (packageLower.contains('game') || 
               packageLower.contains('play')) {
      return 'gaming';
    } else if (packageLower.contains('video') || 
               packageLower.contains('youtube') ||
               packageLower.contains('netflix')) {
      return 'entertainment';
    } else if (packageLower.contains('news') || 
               packageLower.contains('read')) {
      return 'news';
    } else if (packageLower.contains('shop') || 
               packageLower.contains('amazon')) {
      return 'shopping';
    } else {
      return 'productivity';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: AppTheme.gradientCardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
              if (_aiInsight != null && _aiInsight!.length > 150) ...[
                const SizedBox(height: 8),
                _buildExpandButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.psychology,
            color: AppTheme.primaryPurple,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Personalized recommendations',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (_isLoadingInsight)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadAIInsight,
            tooltip: 'Refresh insights',
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoadingInsight) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Generating personalized insights...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_aiInsight == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to generate insights',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    final displayText = _isExpanded || _aiInsight!.length <= 150
        ? _aiInsight!
        : '${_aiInsight!.substring(0, 150)}...';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
      ),
      child: Text(
        displayText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => setState(() => _isExpanded = !_isExpanded),
        icon: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          size: 16,
        ),
        label: Text(_isExpanded ? 'Show Less' : 'Show More'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryPurple,
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
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
}