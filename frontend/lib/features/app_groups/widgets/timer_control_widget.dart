import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/app_group.dart';
import '../../../core/models/timer_session.dart';
import '../../../core/providers/app_providers.dart';

class TimerControlWidget extends ConsumerStatefulWidget {
  final AppGroup appGroup;
  final TimerSession? timerSession;
  final VoidCallback? onTimerUpdated;

  const TimerControlWidget({
    super.key,
    required this.appGroup,
    this.timerSession,
    this.onTimerUpdated,
  });

  @override
  ConsumerState<TimerControlWidget> createState() => _TimerControlWidgetState();
}

class _TimerControlWidgetState extends ConsumerState<TimerControlWidget> {
  bool _isLoading = false;

  Future<void> _startTimer() async {
    setState(() => _isLoading = true);
    
    try {
      final newSession = TimerSession(
        groupId: widget.appGroup.id,
        startTime: DateTime.now(),
        elapsedTime: widget.timerSession?.elapsedTime ?? Duration.zero,
        isActive: true,
      );
      
      await ref.read(timerSessionsProvider.notifier).updateTimerSession(newSession);
      widget.onTimerUpdated?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timer started for "${widget.appGroup.name}"'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting timer: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pauseTimer() async {
    if (widget.timerSession == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final currentTime = DateTime.now();
      final sessionStartTime = widget.timerSession!.lastPauseTime ?? widget.timerSession!.startTime;
      final additionalElapsed = currentTime.difference(sessionStartTime);
      final totalElapsed = widget.timerSession!.elapsedTime + additionalElapsed;
      
      final pausedSession = widget.timerSession!.copyWith(
        elapsedTime: totalElapsed,
        isActive: false,
        lastPauseTime: currentTime,
      );
      
      await ref.read(timerSessionsProvider.notifier).updateTimerSession(pausedSession);
      widget.onTimerUpdated?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timer paused for "${widget.appGroup.name}"'),
            backgroundColor: AppTheme.warningColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error pausing timer: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _stopTimer() async {
    if (widget.timerSession == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final stoppedSession = widget.timerSession!.copyWith(
        elapsedTime: Duration.zero,
        isActive: false,
        lastPauseTime: null,
      );
      
      await ref.read(timerSessionsProvider.notifier).updateTimerSession(stoppedSession);
      widget.onTimerUpdated?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timer stopped for "${widget.appGroup.name}"'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping timer: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addTime(Duration additionalTime) async {
    setState(() => _isLoading = true);
    
    try {
      final updatedGroup = widget.appGroup.copyWith(
        timeLimit: widget.appGroup.timeLimit + additionalTime,
      );
      
      await ref.read(appGroupsProvider.notifier).updateAppGroup(updatedGroup);
      widget.onTimerUpdated?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${_formatDuration(additionalTime)} to "${widget.appGroup.name}"'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding time: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.timerSession?.isActive ?? false;
    final remainingTime = _calculateRemainingTime();
    final progress = _calculateProgress();
    final isTimeUp = remainingTime.inSeconds <= 0 && isActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive 
            ? (isTimeUp ? AppTheme.errorColor.withValues(alpha: 0.1) : AppTheme.primaryPurple.withValues(alpha: 0.1))
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: isActive 
            ? Border.all(color: isTimeUp ? AppTheme.errorColor : AppTheme.primaryPurple, width: 2)
            : null,
      ),
      child: Column(
        children: [
          _buildTimerDisplay(context, isActive, remainingTime, progress, isTimeUp),
          const SizedBox(height: 16),
          _buildControlButtons(context, isActive),
          if (isActive) ...[
            const SizedBox(height: 12),
            _buildQuickTimeButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, bool isActive, Duration remainingTime, double progress, bool isTimeUp) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? (isTimeUp ? Icons.timer_off : Icons.timer) : Icons.timer_off,
                  color: isActive ? (isTimeUp ? AppTheme.errorColor : AppTheme.primaryPurple) : AppTheme.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? (isTimeUp ? 'Time Up!' : 'Active') : 'Inactive',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isActive ? (isTimeUp ? AppTheme.errorColor : AppTheme.primaryPurple) : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              _formatDuration(remainingTime),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isActive ? (isTimeUp ? AppTheme.errorColor : AppTheme.primaryPurple) : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            isTimeUp ? AppTheme.errorColor : 
            (remainingTime.inMinutes <= 5 ? AppTheme.warningColor : AppTheme.primaryPurple),
          ),
          minHeight: 6,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Limit: ${_formatDuration(widget.appGroup.timeLimit)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            if (widget.timerSession != null)
              Text(
                'Used: ${_formatDuration(widget.timerSession!.elapsedTime)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context, bool isActive) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _stopTimer,
            icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.stop, size: 18),
            label: const Text('Stop'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: const BorderSide(color: AppTheme.errorColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : (isActive ? _pauseTimer : _startTimer),
            icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(isActive ? Icons.pause : Icons.play_arrow, size: 18),
            label: Text(isActive ? 'Pause' : 'Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppTheme.warningColor : AppTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTimeButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add Time:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickTimeButton('+5m', const Duration(minutes: 5)),
            const SizedBox(width: 8),
            _buildQuickTimeButton('+10m', const Duration(minutes: 10)),
            const SizedBox(width: 8),
            _buildQuickTimeButton('+15m', const Duration(minutes: 15)),
            const SizedBox(width: 8),
            _buildQuickTimeButton('+30m', const Duration(minutes: 30)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickTimeButton(String label, Duration duration) {
    return Expanded(
      child: OutlinedButton(
        onPressed: _isLoading ? null : () => _addTime(duration),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryPurple,
          side: BorderSide(color: AppTheme.primaryPurple.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 8),
          minimumSize: const Size(0, 32),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Duration _calculateRemainingTime() {
    if (widget.timerSession == null) {
      return widget.appGroup.timeLimit;
    }

    Duration elapsed = widget.timerSession!.elapsedTime;
    
    if (widget.timerSession!.isActive) {
      final currentTime = DateTime.now();
      final sessionStartTime = widget.timerSession!.lastPauseTime ?? widget.timerSession!.startTime;
      final additionalElapsed = currentTime.difference(sessionStartTime);
      elapsed = elapsed + additionalElapsed;
    }

    final remaining = widget.appGroup.timeLimit - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double _calculateProgress() {
    if (widget.timerSession == null) {
      return 0.0;
    }

    Duration elapsed = widget.timerSession!.elapsedTime;
    
    if (widget.timerSession!.isActive) {
      final currentTime = DateTime.now();
      final sessionStartTime = widget.timerSession!.lastPauseTime ?? widget.timerSession!.startTime;
      final additionalElapsed = currentTime.difference(sessionStartTime);
      elapsed = elapsed + additionalElapsed;
    }

    final total = widget.appGroup.timeLimit.inMilliseconds;
    return total > 0 ? (elapsed.inMilliseconds / total).clamp(0.0, 1.0) : 0.0;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}