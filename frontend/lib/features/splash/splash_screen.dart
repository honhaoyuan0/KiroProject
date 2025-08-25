import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/app_providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitializationProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryPurple,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 64,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // App name
                    const Text(
                      'WiseScreen',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // App tagline
                    Text(
                      'Smart Screen Time Management',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Status indicator
                    _buildStatusIndicator(context, initState),
                  ],
                ),
              ),
            ),
            
            // Bottom section with status or actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildBottomSection(context, ref, initState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, AppInitializationState state) {
    switch (state.status) {
      case AppInitializationStatus.loading:
        return Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Initializing app...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
          ],
        );
        
      case AppInitializationStatus.permissionsRequired:
        return Column(
          children: [
            Icon(
              Icons.security,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 16),
            Text(
              'Permissions Required',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'WiseScreen needs permissions to monitor your app usage',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
        
      case AppInitializationStatus.ready:
        return Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to go!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        
      case AppInitializationStatus.error:
        return Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 16),
            Text(
              'Initialization Error',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'An unexpected error occurred',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }

  Widget _buildBottomSection(BuildContext context, WidgetRef ref, AppInitializationState state) {
    switch (state.status) {
      case AppInitializationStatus.loading:
        return const SizedBox.shrink();
        
      case AppInitializationStatus.permissionsRequired:
        return Column(
          children: [
            // Permission status indicators
            _buildPermissionStatus('Usage Stats', state.hasUsageStatsPermission),
            const SizedBox(height: 8),
            _buildPermissionStatus('System Overlay', state.hasOverlayPermission),
            const SizedBox(height: 24),
            
            // Grant permissions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(appInitializationProvider.notifier).requestPermissions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Grant Permissions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
        
      case AppInitializationStatus.ready:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        
      case AppInitializationStatus.error:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(appInitializationProvider.notifier).retry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }
  }

  Widget _buildPermissionStatus(String name, bool granted) {
    return Row(
      children: [
        Icon(
          granted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: granted 
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          name,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}