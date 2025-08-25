import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';

class TimerSettingsPage extends ConsumerStatefulWidget {
  const TimerSettingsPage({super.key});

  @override
  ConsumerState<TimerSettingsPage> createState() => _TimerSettingsPageState();
}

class _TimerSettingsPageState extends ConsumerState<TimerSettingsPage> {
  // Timer notification settings
  bool _enableNotifications = true;
  bool _enableWarningNotifications = true;
  bool _enableTimeUpNotifications = true;
  bool _enableBreakReminders = false;
  
  // Warning timing settings
  int _warningMinutes = 5;
  int _breakReminderMinutes = 30;
  
  // Sound and vibration settings
  bool _enableSounds = true;
  bool _enableVibration = true;
  String _selectedNotificationSound = 'Default';
  
  // Auto-pause settings
  bool _autoPauseOnScreenOff = true;
  bool _autoPauseOnAppSwitch = false;
  
  // Display settings
  bool _showTimerInNotificationBar = true;
  bool _showProgressInOverlay = true;
  
  final List<String> _notificationSounds = [
    'Default',
    'Bell',
    'Chime',
    'Ding',
    'Gentle',
    'None',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Settings'),
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          _buildTimingSettings(),
          const SizedBox(height: 24),
          _buildSoundSettings(),
          const SizedBox(height: 24),
          _buildAutoPauseSettings(),
          const SizedBox(height: 24),
          _buildDisplaySettings(),
          const SizedBox(height: 24),
          _buildAdvancedSettings(),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          title: 'Enable Notifications',
          subtitle: 'Receive timer notifications and alerts',
          value: _enableNotifications,
          onChanged: (value) => setState(() => _enableNotifications = value),
        ),
        _buildSwitchTile(
          title: 'Warning Notifications',
          subtitle: 'Get notified when time is running low',
          value: _enableWarningNotifications,
          onChanged: _enableNotifications 
              ? (value) => setState(() => _enableWarningNotifications = value)
              : null,
        ),
        _buildSwitchTile(
          title: 'Time Up Notifications',
          subtitle: 'Get notified when timer reaches limit',
          value: _enableTimeUpNotifications,
          onChanged: _enableNotifications 
              ? (value) => setState(() => _enableTimeUpNotifications = value)
              : null,
        ),
        _buildSwitchTile(
          title: 'Break Reminders',
          subtitle: 'Periodic reminders to take breaks',
          value: _enableBreakReminders,
          onChanged: _enableNotifications 
              ? (value) => setState(() => _enableBreakReminders = value)
              : null,
        ),
      ],
    );
  }

  Widget _buildTimingSettings() {
    return _buildSettingsSection(
      title: 'Timing',
      icon: Icons.schedule,
      children: [
        _buildSliderTile(
          title: 'Warning Time',
          subtitle: 'Show warning $_warningMinutes minutes before limit',
          value: _warningMinutes.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          onChanged: _enableWarningNotifications 
              ? (value) => setState(() => _warningMinutes = value.round())
              : null,
        ),
        _buildSliderTile(
          title: 'Break Reminder Interval',
          subtitle: 'Remind to take breaks every $_breakReminderMinutes minutes',
          value: _breakReminderMinutes.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          onChanged: _enableBreakReminders 
              ? (value) => setState(() => _breakReminderMinutes = value.round())
              : null,
        ),
      ],
    );
  }

  Widget _buildSoundSettings() {
    return _buildSettingsSection(
      title: 'Sound & Vibration',
      icon: Icons.volume_up,
      children: [
        _buildSwitchTile(
          title: 'Enable Sounds',
          subtitle: 'Play sounds for timer notifications',
          value: _enableSounds,
          onChanged: (value) => setState(() => _enableSounds = value),
        ),
        _buildSwitchTile(
          title: 'Enable Vibration',
          subtitle: 'Vibrate for timer notifications',
          value: _enableVibration,
          onChanged: (value) => setState(() => _enableVibration = value),
        ),
        _buildDropdownTile(
          title: 'Notification Sound',
          subtitle: 'Choose notification sound',
          value: _selectedNotificationSound,
          items: _notificationSounds,
          onChanged: _enableSounds 
              ? (value) => setState(() => _selectedNotificationSound = value!)
              : null,
        ),
      ],
    );
  }

  Widget _buildAutoPauseSettings() {
    return _buildSettingsSection(
      title: 'Auto-Pause',
      icon: Icons.pause_circle,
      children: [
        _buildSwitchTile(
          title: 'Pause on Screen Off',
          subtitle: 'Automatically pause timer when screen turns off',
          value: _autoPauseOnScreenOff,
          onChanged: (value) => setState(() => _autoPauseOnScreenOff = value),
        ),
        _buildSwitchTile(
          title: 'Pause on App Switch',
          subtitle: 'Pause timer when switching away from group apps',
          value: _autoPauseOnAppSwitch,
          onChanged: (value) => setState(() => _autoPauseOnAppSwitch = value),
        ),
      ],
    );
  }

  Widget _buildDisplaySettings() {
    return _buildSettingsSection(
      title: 'Display',
      icon: Icons.display_settings,
      children: [
        _buildSwitchTile(
          title: 'Show Timer in Notification Bar',
          subtitle: 'Display active timer in persistent notification',
          value: _showTimerInNotificationBar,
          onChanged: (value) => setState(() => _showTimerInNotificationBar = value),
        ),
        _buildSwitchTile(
          title: 'Show Progress in Overlay',
          subtitle: 'Display progress bar in system overlay',
          value: _showProgressInOverlay,
          onChanged: (value) => setState(() => _showProgressInOverlay = value),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return _buildSettingsSection(
      title: 'Advanced',
      icon: Icons.settings,
      children: [
        _buildActionTile(
          title: 'Export Timer Data',
          subtitle: 'Export timer history and statistics',
          icon: Icons.download,
          onTap: _exportTimerData,
        ),
        _buildActionTile(
          title: 'Clear Timer History',
          subtitle: 'Delete all timer session history',
          icon: Icons.delete_forever,
          onTap: _clearTimerHistory,
          isDestructive: true,
        ),
        _buildActionTile(
          title: 'Test Notifications',
          subtitle: 'Send a test notification',
          icon: Icons.notification_add,
          onTap: _testNotifications,
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryPurple,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double>? onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppTheme.primaryPurple,
            inactiveColor: AppTheme.primaryPurple.withValues(alpha: 0.3),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryPurple),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : AppTheme.primaryPurple,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorColor : null,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all timer settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _enableNotifications = true;
                _enableWarningNotifications = true;
                _enableTimeUpNotifications = true;
                _enableBreakReminders = false;
                _warningMinutes = 5;
                _breakReminderMinutes = 30;
                _enableSounds = true;
                _enableVibration = true;
                _selectedNotificationSound = 'Default';
                _autoPauseOnScreenOff = true;
                _autoPauseOnAppSwitch = false;
                _showTimerInNotificationBar = true;
                _showProgressInOverlay = true;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _exportTimerData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timer data export feature coming soon'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }

  void _clearTimerHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Timer History'),
        content: const Text('Are you sure you want to delete all timer session history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Timer history cleared'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _testNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}