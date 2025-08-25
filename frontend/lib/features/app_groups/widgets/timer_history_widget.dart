import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/app_group.dart';
import '../../../core/models/timer_session.dart';

class TimerHistoryWidget extends ConsumerStatefulWidget {
  final AppGroup appGroup;

  const TimerHistoryWidget({
    super.key,
    required this.appGroup,
  });

  @override
  ConsumerState<TimerHistoryWidget> createState() => _TimerHistoryWidgetState();
}

class _TimerHistoryWidgetState extends ConsumerState<TimerHistoryWidget> {
  List<TimerHistoryEntry> _historyEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      // In a real implementation, this would load from database
      // For now, we'll generate some sample data
      _historyEntries = _generateSampleHistory();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<TimerHistoryEntry> _generateSampleHistory() {
    final now = DateTime.now();
    return [
      TimerHistoryEntry(
        date: now.subtract(const Duration(hours: 2)),
        duration: const Duration(minutes: 45),
        completed: true,
        timeLimit: widget.appGroup.timeLimit,
      ),
      TimerHistoryEntry(
        date: now.subtract(const Duration(days: 1)),
        duration: const Duration(minutes: 30),
        completed: false,
        timeLimit: widget.appGroup.timeLimit,
      ),
      TimerHistoryEntry(
        date: now.subtract(const Duration(days: 2)),
        duration: const Duration(hours: 1, minutes: 15),
        completed: true,
        timeLimit: widget.appGroup.timeLimit,
      ),
      TimerHistoryEntry(
        date: now.subtract(const Duration(days: 3)),
        duration: const Duration(minutes: 20),
        completed: false,
        timeLimit: widget.appGroup.timeLimit,
      ),
      TimerHistoryEntry(
        date: now.subtract(const Duration(days: 4)),
        duration: const Duration(minutes: 55),
        completed: true,
        timeLimit: widget.appGroup.timeLimit,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_historyEntries.isEmpty)
            _buildEmptyState(context)
          else
            _buildHistoryList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final totalSessions = _historyEntries.length;
    final completedSessions = _historyEntries.where((e) => e.completed).length;
    final totalTime = _historyEntries.fold<Duration>(
      Duration.zero,
      (sum, entry) => sum + entry.duration,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.history,
              color: AppTheme.primaryPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Timer History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatChip('$totalSessions Sessions', Icons.play_circle_outline),
            const SizedBox(width: 8),
            _buildStatChip('$completedSessions Completed', Icons.check_circle_outline),
            const SizedBox(width: 8),
            _buildStatChip(_formatDuration(totalTime), Icons.access_time),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryPurple),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 48,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No timer history yet',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start using timers to see your session history',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return Column(
      children: _historyEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final historyEntry = entry.value;
        final isLast = index == _historyEntries.length - 1;
        
        return Column(
          children: [
            _buildHistoryItem(context, historyEntry),
            if (!isLast) const Divider(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHistoryItem(BuildContext context, TimerHistoryEntry entry) {
    final progress = entry.duration.inMilliseconds / entry.timeLimit.inMilliseconds;
    final isOvertime = progress > 1.0;
    
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: entry.completed 
                ? AppTheme.successColor 
                : (isOvertime ? AppTheme.errorColor : AppTheme.warningColor),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatRelativeDate(entry.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDuration(entry.duration),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOvertime ? AppTheme.errorColor : AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOvertime ? AppTheme.errorColor : AppTheme.primaryPurple,
                      ),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    entry.completed ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: entry.completed 
                        ? AppTheme.successColor 
                        : (isOvertime ? AppTheme.errorColor : AppTheme.warningColor),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${(progress * 100).toInt()}% of ${_formatDuration(entry.timeLimit)} limit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return '${difference.inHours} hours ago';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class TimerHistoryEntry {
  final DateTime date;
  final Duration duration;
  final bool completed;
  final Duration timeLimit;

  const TimerHistoryEntry({
    required this.date,
    required this.duration,
    required this.completed,
    required this.timeLimit,
  });
}