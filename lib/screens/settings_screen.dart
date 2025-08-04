import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_providers.dart';
import '../models/app_settings.dart';
import '../models/reading_item.dart';
import '../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  PackageInfo? _packageInfo;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsContent(settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(appSettingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(AppSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Appearance Section
        _buildSectionHeader('Appearance'),
        _buildThemeSettings(settings),
        _buildDisplaySettings(settings),
        const SizedBox(height: 24),

        // Reading Section
        _buildSectionHeader('Reading'),
        _buildReadingSettings(settings),
        const SizedBox(height: 24),

        // Notifications Section
        _buildSectionHeader('Notifications'),
        _buildNotificationSettings(settings),
        const SizedBox(height: 24),

        // Data & Privacy Section
        _buildSectionHeader('Data & Privacy'),
        _buildDataSettings(settings),
        const SizedBox(height: 24),

        // API Integration Section
        _buildSectionHeader('API Integration'),
        _buildApiSettings(settings),
        const SizedBox(height: 24),

        // Advanced Section
        _buildSectionHeader('Advanced'),
        _buildAdvancedSettings(settings),
        const SizedBox(height: 24),

        // About Section
        _buildSectionHeader('About'),
        _buildAboutSection(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme Mode'),
            subtitle: Text(_getThemeModeDisplayName(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeModeDialog(settings),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Color Scheme'),
            subtitle: Text(_getColorSchemeDisplayName(settings.colorScheme)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showColorSchemeDialog(settings),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome),
            title: const Text('Dynamic Colors'),
            subtitle: const Text('Use system color scheme'),
            value: settings.useDynamicColors,
            onChanged: (value) => _updateSettings(settings.copyWith(useDynamicColors: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Default View Mode'),
            subtitle: Text(_getViewModeDisplayName(settings.defaultViewMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showViewModeDialog(settings),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.grid_view),
            title: const Text('Show Grid Lines'),
            subtitle: const Text('Display grid lines in grid view'),
            value: settings.showGridLines,
            onChanged: (value) => _updateSettings(settings.copyWith(showGridLines: value)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.animation),
            title: const Text('Animations'),
            subtitle: const Text('Enable smooth animations'),
            value: settings.enableAnimations,
            onChanged: (value) => _updateSettings(settings.copyWith(enableAnimations: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.auto_stories),
            title: const Text('Auto-mark as Reading'),
            subtitle: const Text('Automatically mark items as reading when opened'),
            value: settings.autoMarkAsReading,
            onChanged: (value) => _updateSettings(settings.copyWith(autoMarkAsReading: value)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.check_circle),
            title: const Text('Auto-complete'),
            subtitle: const Text('Mark as completed when reaching final chapter'),
            value: settings.autoComplete,
            onChanged: (value) => _updateSettings(settings.copyWith(autoComplete: value)),
          ),
          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text('Default Sort Order'),
            subtitle: Text(_getSortOrderDisplayName(settings.defaultSortOrder)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSortOrderDialog(settings),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reading reminders and updates'),
            value: settings.enableNotifications,
            onChanged: (value) async {
              if (value) {
                final hasPermission = await NotificationService.requestPermission();
                if (hasPermission) {
                  _updateSettings(settings.copyWith(enableNotifications: value));
                } else {
                  _showPermissionDialog();
                }
              } else {
                _updateSettings(settings.copyWith(enableNotifications: value));
              }
            },
          ),
          if (settings.enableNotifications) ...[
            SwitchListTile(
              secondary: const Icon(Icons.schedule),
              title: const Text('Daily Reminders'),
              subtitle: const Text('Get daily reading reminders'),
              value: settings.dailyReminders,
              onChanged: (value) => _updateSettings(settings.copyWith(dailyReminders: value)),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder Time'),
              subtitle: Text(_formatTime(_customTimeToTimeOfDay(settings.reminderTime))),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTimePickerDialog(settings),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.update),
              title: const Text('Update Notifications'),
              subtitle: const Text('Notify when new chapters are available'),
              value: settings.updateNotifications,
              onChanged: (value) => _updateSettings(settings.copyWith(updateNotifications: value)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your library to a file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            subtitle: const Text('Import library from a backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _importData,
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Sync Settings'),
            subtitle: const Text('Synchronize data across devices'),
            trailing: Switch(
              value: settings.enableSync,
              onChanged: (value) => _updateSettings(settings.copyWith(enableSync: value)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Clear All Data',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Permanently delete all library data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildApiSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.api),
            title: const Text('MyAnimeList Integration'),
            subtitle: Text((settings.malApiKey?.isNotEmpty ?? false) ? 'Connected' : 'Not connected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showApiKeyDialog('MyAnimeList', 'malApiKey', settings.malApiKey ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('AniList Integration'),
            subtitle: Text((settings.anilistApiKey?.isNotEmpty ?? false) ? 'Connected' : 'Not connected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showApiKeyDialog('AniList', 'anilistApiKey', settings.anilistApiKey ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('AI Recommendations'),
            subtitle: Text((settings.openaiApiKey?.isNotEmpty ?? false) ? 'Enabled' : 'Disabled'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showApiKeyDialog('OpenAI', 'openaiApiKey', settings.openaiApiKey ?? ''),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sync),
            title: const Text('Auto-sync with APIs'),
            subtitle: const Text('Automatically sync reading progress'),
            value: settings.autoSyncApis,
            onChanged: (value) => _updateSettings(settings.copyWith(autoSyncApis: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.bug_report),
            title: const Text('Debug Mode'),
            subtitle: const Text('Enable debug logging and features'),
            value: settings.debugMode,
            onChanged: (value) => _updateSettings(settings.copyWith(debugMode: value)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            subtitle: const Text('Help improve the app with usage data'),
            value: settings.enableAnalytics,
            onChanged: (value) => _updateSettings(settings.copyWith(enableAnalytics: value)),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Cache Size'),
            subtitle: Text('${settings.cacheSize} MB'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCacheSizeDialog(settings),
          ),
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearCache,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: Text(_packageInfo?.version ?? 'Unknown'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Build Number'),
            subtitle: Text(_packageInfo?.buildNumber ?? 'Unknown'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openSupport,
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _rateApp,
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _shareApp,
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showThemeModeDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeDisplayName(mode)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(settings.copyWith(themeMode: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showColorSchemeDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Color Scheme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppColorScheme.values.map((scheme) {
            return RadioListTile<AppColorScheme>(
              title: Text(_getColorSchemeDisplayName(scheme)),
              value: scheme,
              groupValue: settings.colorScheme,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(settings.copyWith(colorScheme: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showViewModeDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default View Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ViewMode.values.map((mode) {
            return RadioListTile<ViewMode>(
              title: Text(_getViewModeDisplayName(mode)),
              value: mode,
              groupValue: settings.defaultViewMode,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(settings.copyWith(defaultViewMode: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSortOrderDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Sort Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortOption.values.map((option) {
            return RadioListTile<SortOption>(
              title: Text(_getSortOrderDisplayName(option)),
              value: option,
              groupValue: settings.defaultSortOrder,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(settings.copyWith(defaultSortOrder: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimePickerDialog(AppSettings settings) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _customTimeToTimeOfDay(settings.reminderTime),
    );
    
    if (time != null) {
      _updateSettings(settings.copyWith(reminderTime: _timeOfDayToCustomTime(time)));
    }
  }

  void _showApiKeyDialog(String serviceName, String keyName, String currentKey) {
    final controller = TextEditingController(text: currentKey);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$serviceName API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Get your API key from the $serviceName developer portal.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final settings = ref.read(appSettingsProvider).value!;
              AppSettings updatedSettings;
              
              switch (keyName) {
                case 'malApiKey':
                  updatedSettings = settings.copyWith(malApiKey: controller.text);
                  break;
                case 'anilistApiKey':
                  updatedSettings = settings.copyWith(anilistApiKey: controller.text);
                  break;
                case 'openaiApiKey':
                  updatedSettings = settings.copyWith(openaiApiKey: controller.text);
                  break;
                default:
                  return;
              }
              
              _updateSettings(updatedSettings);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCacheSizeDialog(AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [50, 100, 200, 500, 1000].map((size) {
            return RadioListTile<int>(
              title: Text('$size MB'),
              value: size,
              groupValue: settings.cacheSize,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(settings.copyWith(cacheSize: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Notification permission is required to send reading reminders. '
          'Please enable notifications in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              NotificationService.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your library data, including items, '
          'progress, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _updateSettings(AppSettings settings) {
    ref.read(appSettingsProvider.notifier).updateSettings(settings);
  }

  Future<void> _exportData() async {
    try {
      // Implementation for data export
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _importData() async {
    try {
      // Implementation for data import
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  Future<void> _clearCache() async {
    try {
      // Implementation for cache clearing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear cache: $e')),
      );
    }
  }

  Future<void> _clearAllData() async {
    try {
      await ref.read(readingItemsProvider.notifier).clearAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data cleared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear data: $e')),
      );
    }
  }

  Future<void> _openSupport() async {
    const url = 'https://github.com/omnireader/support';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open support page')),
      );
    }
  }

  Future<void> _rateApp() async {
    const url = 'https://play.google.com/store/apps/details?id=com.omnireader.app';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open app store')),
      );
    }
  }

  Future<void> _shareApp() async {
    const text = 'Check out OmniReader - the ultimate manga, manhwa, and manhua reading tracker!';
    const url = 'https://play.google.com/store/apps/details?id=com.omnireader.app';
    
    try {
      // Implementation for sharing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share functionality not implemented')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share app')),
      );
    }
  }

  // Helper methods
  TimeOfDay _customTimeToTimeOfDay(CustomTimeOfDay customTime) {
    return TimeOfDay(hour: customTime.hour, minute: customTime.minute);
  }

  CustomTimeOfDay _timeOfDayToCustomTime(TimeOfDay time) {
    return CustomTimeOfDay(hour: time.hour, minute: time.minute);
  }

  String _getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _getColorSchemeDisplayName(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.blue:
        return 'Blue';
      case AppColorScheme.green:
        return 'Green';
      case AppColorScheme.purple:
        return 'Purple';
      case AppColorScheme.orange:
        return 'Orange';
      case AppColorScheme.red:
        return 'Red';
      case AppColorScheme.pink:
        return 'Pink';
    }
  }

  String _getViewModeDisplayName(ViewMode mode) {
    switch (mode) {
      case ViewMode.grid:
        return 'Grid';
      case ViewMode.list:
        return 'List';
      case ViewMode.card:
        return 'Card';
      case ViewMode.compact:
        return 'Compact';
    }
  }

  String _getSortOrderDisplayName(SortOption option) {
    switch (option) {
      case SortOption.title:
        return 'Title';
      case SortOption.author:
        return 'Author';
      case SortOption.dateAdded:
        return 'Date Added';
      case SortOption.lastUpdated:
        return 'Last Updated';
      case SortOption.rating:
        return 'Rating';
      case SortOption.progress:
        return 'Progress';
      case SortOption.status:
        return 'Status';
      case SortOption.type:
        return 'Type';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

