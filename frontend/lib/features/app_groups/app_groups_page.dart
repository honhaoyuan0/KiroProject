import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/app_group.dart';
import '../../core/models/timer_session.dart';
import '../../core/providers/app_providers.dart';
import 'widgets/app_group_card.dart';
import 'widgets/app_group_form_dialog.dart';
import 'widgets/delete_confirmation_dialog.dart';

class AppGroupsPage extends ConsumerStatefulWidget {
  const AppGroupsPage({super.key});

  @override
  ConsumerState<AppGroupsPage> createState() => _AppGroupsPageState();
}

class _AppGroupsPageState extends ConsumerState<AppGroupsPage> {
  @override
  void initState() {
    super.initState();
    // Load timer sessions when app groups are loaded
    ref.read(appGroupsProvider.notifier).loadAppGroups();
  }

  Future<void> _loadTimerSessions(List<AppGroup> appGroups) async {
    final groupIds = appGroups.map((group) => group.id).toList();
    await ref.read(timerSessionsProvider.notifier).loadAllTimerSessions(groupIds);
  }

  Future<void> _createAppGroup() async {
    final result = await showDialog<AppGroup>(
      context: context,
      builder: (context) => const AppGroupFormDialog(),
    );
    
    if (result != null) {
      try {
        await ref.read(appGroupsProvider.notifier).addAppGroup(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('App group "${result.name}" created successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating app group: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _editAppGroup(AppGroup appGroup) async {
    final result = await showDialog<AppGroup>(
      context: context,
      builder: (context) => AppGroupFormDialog(appGroup: appGroup),
    );
    
    if (result != null) {
      try {
        await ref.read(appGroupsProvider.notifier).updateAppGroup(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('App group "${result.name}" updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating app group: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAppGroup(AppGroup appGroup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete App Group',
        content: 'Are you sure you want to delete "${appGroup.name}"? This action cannot be undone.',
      ),
    );
    
    if (confirmed == true) {
      try {
        await ref.read(appGroupsProvider.notifier).deleteAppGroup(appGroup.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('App group "${appGroup.name}" deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting app group: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appGroupsAsync = ref.watch(appGroupsProvider);
    final timerSessions = ref.watch(timerSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(appGroupsProvider.notifier).loadAppGroups(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: appGroupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(error.toString()),
        data: (appGroups) {
          // Load timer sessions when app groups are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadTimerSessions(appGroups);
          });
          
          return _buildBody(appGroups, timerSessions);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAppGroup,
        tooltip: 'Create App Group',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(List<AppGroup> appGroups, Map<String, TimerSession?> timerSessions) {
    if (appGroups.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(appGroupsProvider.notifier).loadAppGroups(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appGroups.length,
        itemBuilder: (context, index) {
          final appGroup = appGroups[index];
          final timerSession = timerSessions[appGroup.id];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppGroupCard(
              appGroup: appGroup,
              timerSession: timerSession,
              onEdit: () => _editAppGroup(appGroup),
              onDelete: () => _deleteAppGroup(appGroup),
              onTimerAction: () => ref.read(appGroupsProvider.notifier).loadAppGroups(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading App Groups',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(appGroupsProvider.notifier).loadAppGroups(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apps,
            size: 64,
            color: AppTheme.primaryPurple.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No App Groups Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first app group to start managing your screen time',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createAppGroup,
            icon: const Icon(Icons.add),
            label: const Text('Create App Group'),
          ),
        ],
      ),
    );
  }
}