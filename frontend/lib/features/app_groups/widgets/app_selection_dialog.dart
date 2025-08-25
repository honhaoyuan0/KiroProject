import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class AppSelectionDialog extends StatefulWidget {
  final List<String> selectedApps;

  const AppSelectionDialog({
    super.key,
    required this.selectedApps,
  });

  @override
  State<AppSelectionDialog> createState() => _AppSelectionDialogState();
}

class _AppSelectionDialogState extends State<AppSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<InstalledApp> _allApps = [];
  List<InstalledApp> _filteredApps = [];
  Set<String> _selectedAppPackages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedAppPackages = Set.from(widget.selectedApps);
    _loadInstalledApps();
    _searchController.addListener(_filterApps);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstalledApps() async {
    setState(() => _isLoading = true);
    
    try {
      // For now, using mock data since installed_apps package is commented out
      // In a real implementation, you would use:
      // final apps = await InstalledApps.getInstalledApps(true, true);
      _allApps = _getMockInstalledApps();
      _filteredApps = List.from(_allApps);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading apps: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredApps = List.from(_allApps);
      } else {
        _filteredApps = _allApps.where((app) {
          return app.name.toLowerCase().contains(query) ||
                 app.packageName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(child: _buildAppsList()),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Apps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_selectedAppPackages.length} selected',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search apps...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildAppsList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading installed apps...'),
          ],
        ),
      );
    }

    if (_filteredApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No apps found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search terms',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredApps.length,
      itemBuilder: (context, index) {
        final app = _filteredApps[index];
        final isSelected = _selectedAppPackages.contains(app.packageName);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedAppPackages.add(app.packageName);
                } else {
                  _selectedAppPackages.remove(app.packageName);
                }
              });
            },
            title: Text(
              app.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              app.packageName,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getAppIcon(app.packageName),
                color: AppTheme.primaryPurple,
              ),
            ),
            activeColor: AppTheme.primaryPurple,
            checkColor: Colors.white,
          ),
        );
      },
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedAppPackages.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
              const Spacer(),
              Text(
                '${_selectedAppPackages.length} selected',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
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
                  onPressed: () {
                    Navigator.of(context).pop(_selectedAppPackages.toList());
                  },
                  child: const Text('Select'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<InstalledApp> _getMockInstalledApps() {
    // Mock data for testing - replace with real installed apps in production
    return [
      InstalledApp('Instagram', 'com.instagram.android'),
      InstalledApp('Facebook', 'com.facebook.katana'),
      InstalledApp('Twitter', 'com.twitter.android'),
      InstalledApp('TikTok', 'com.zhiliaoapp.musically'),
      InstalledApp('YouTube', 'com.google.android.youtube'),
      InstalledApp('WhatsApp', 'com.whatsapp'),
      InstalledApp('Telegram', 'org.telegram.messenger'),
      InstalledApp('Discord', 'com.discord'),
      InstalledApp('Reddit', 'com.reddit.frontpage'),
      InstalledApp('Snapchat', 'com.snapchat.android'),
      InstalledApp('LinkedIn', 'com.linkedin.android'),
      InstalledApp('Pinterest', 'com.pinterest'),
      InstalledApp('Spotify', 'com.spotify.music'),
      InstalledApp('Netflix', 'com.netflix.mediaclient'),
      InstalledApp('Amazon Prime Video', 'com.amazon.avod.thirdpartyclient'),
      InstalledApp('Disney+', 'com.disney.disneyplus'),
      InstalledApp('Twitch', 'tv.twitch.android.app'),
      InstalledApp('Chrome', 'com.android.chrome'),
      InstalledApp('Firefox', 'org.mozilla.firefox'),
      InstalledApp('Gmail', 'com.google.android.gm'),
      InstalledApp('Google Maps', 'com.google.android.apps.maps'),
      InstalledApp('Uber', 'com.ubercab'),
      InstalledApp('Lyft', 'me.lyft.android'),
      InstalledApp('Amazon Shopping', 'com.amazon.mShop.android.shopping'),
      InstalledApp('eBay', 'com.ebay.mobile'),
      InstalledApp('PayPal', 'com.paypal.android.p2pmobile'),
      InstalledApp('Venmo', 'com.venmo'),
      InstalledApp('Cash App', 'com.squareup.cash'),
      InstalledApp('Robinhood', 'com.robinhood.android'),
      InstalledApp('Coinbase', 'com.coinbase.android'),
    ];
  }

  IconData _getAppIcon(String packageName) {
    // Simple icon mapping based on package name
    if (packageName.contains('instagram')) return Icons.camera_alt;
    if (packageName.contains('facebook')) return Icons.facebook;
    if (packageName.contains('twitter')) return Icons.alternate_email;
    if (packageName.contains('tiktok') || packageName.contains('musically')) return Icons.music_video;
    if (packageName.contains('youtube')) return Icons.play_circle;
    if (packageName.contains('whatsapp')) return Icons.chat;
    if (packageName.contains('telegram')) return Icons.send;
    if (packageName.contains('discord')) return Icons.forum;
    if (packageName.contains('reddit')) return Icons.reddit;
    if (packageName.contains('snapchat')) return Icons.camera;
    if (packageName.contains('linkedin')) return Icons.work;
    if (packageName.contains('pinterest')) return Icons.push_pin;
    if (packageName.contains('spotify')) return Icons.music_note;
    if (packageName.contains('netflix')) return Icons.movie;
    if (packageName.contains('amazon')) return Icons.shopping_cart;
    if (packageName.contains('disney')) return Icons.castle;
    if (packageName.contains('twitch')) return Icons.videogame_asset;
    if (packageName.contains('chrome') || packageName.contains('firefox')) return Icons.web;
    if (packageName.contains('gmail')) return Icons.email;
    if (packageName.contains('maps')) return Icons.map;
    if (packageName.contains('uber') || packageName.contains('lyft')) return Icons.directions_car;
    if (packageName.contains('paypal') || packageName.contains('venmo') || packageName.contains('cash')) return Icons.payment;
    if (packageName.contains('robinhood') || packageName.contains('coinbase')) return Icons.trending_up;
    
    return Icons.android;
  }
}

class InstalledApp {
  final String name;
  final String packageName;

  InstalledApp(this.name, this.packageName);
}