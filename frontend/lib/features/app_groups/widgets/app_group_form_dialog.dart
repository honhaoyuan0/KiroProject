import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/app_group.dart';
import 'app_selection_dialog.dart';

class AppGroupFormDialog extends StatefulWidget {
  final AppGroup? appGroup;

  const AppGroupFormDialog({super.key, this.appGroup});

  @override
  State<AppGroupFormDialog> createState() => _AppGroupFormDialogState();
}

class _AppGroupFormDialogState extends State<AppGroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<String> _selectedApps = [];
  Duration _timeLimit = const Duration(minutes: 30);

  bool get _isEditing => widget.appGroup != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.appGroup!.name;
      _selectedApps = List.from(widget.appGroup!.appPackages);
      _timeLimit = widget.appGroup!.timeLimit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 24),
                      _buildAppSelection(context),
                      const SizedBox(height: 24),
                      _buildTimeLimitSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.primaryPurple,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.apps, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEditing ? 'Edit App Group' : 'Create App Group',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Name',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter group name (e.g., Social Media)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a group name';
            }
            if (value.trim().length < 2) {
              return 'Group name must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAppSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Selected Apps',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAppSelectionDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Apps'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSelectedAppsList(),
      ],
    );
  }

  Widget _buildSelectedAppsList() {
    if (_selectedApps.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Column(
          children: [
            Icon(Icons.apps, size: 32, color: AppTheme.textSecondary),
            SizedBox(height: 8),
            Text(
              'No apps selected',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            Text(
              'Tap "Add Apps" to select apps for this group',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedApps.length} app${_selectedApps.length == 1 ? '' : 's'} selected',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedApps.map((app) => _buildAppChip(app)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppChip(String appPackage) {
    return Chip(
      label: Text(
        _getAppDisplayName(appPackage),
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        setState(() {
          _selectedApps.remove(appPackage);
        });
      },
      backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
      deleteIconColor: AppTheme.primaryPurple,
      side: BorderSide(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
    );
  }

  Widget _buildTimeLimitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Limit',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, color: AppTheme.primaryPurple),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_timeLimit),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTimeLimitButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeLimitButtons() {
    final presetDurations = [
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(minutes: 45),
      const Duration(hours: 1),
      const Duration(hours: 2),
      const Duration(hours: 3),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetDurations.map((duration) {
        final isSelected = _timeLimit == duration;
        return FilterChip(
          label: Text(_formatDuration(duration)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _timeLimit = duration;
              });
            }
          },
          selectedColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.primaryPurple,
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveAppGroup,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppSelectionDialog(BuildContext context) async {
    final selectedApps = await showDialog<List<String>>(
      context: context,
      builder: (context) => AppSelectionDialog(
        selectedApps: _selectedApps,
      ),
    );

    if (selectedApps != null) {
      setState(() {
        _selectedApps = selectedApps;
      });
    }
  }

  void _saveAppGroup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedApps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one app'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final appGroup = AppGroup(
      id: _isEditing ? widget.appGroup!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      appPackages: _selectedApps,
      timeLimit: _timeLimit,
      createdAt: _isEditing ? widget.appGroup!.createdAt : DateTime.now(),
      isActive: _isEditing ? widget.appGroup!.isActive : true,
    );

    Navigator.of(context).pop(appGroup);
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

  String _getAppDisplayName(String packageName) {
    // Extract app name from package name for display
    final parts = packageName.split('.');
    if (parts.isNotEmpty) {
      return parts.last.replaceAll('_', ' ').split(' ').map((word) {
        return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word;
      }).join(' ');
    }
    return packageName;
  }
}