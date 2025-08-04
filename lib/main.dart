import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flex_color_scheme/flex_color_scheme.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'models/reading_item.dart';
import 'models/app_settings.dart';
import 'providers/app_providers.dart';
import 'utils/app_router.dart';
import 'utils/app_theme.dart';
// import 'services/notification_service.dart';

import 'models/theme_mode_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  _registerHiveAdapters();
  
  // Initialize notification service will be done when needed
  
  runApp(
    ProviderScope(
      child: const OmniReaderApp(),
    ),
  );
}

void _registerHiveAdapters() {
  // Register all the Hive type adapters
  Hive.registerAdapter(ReadingItemAdapter());
  Hive.registerAdapter(ReadingTypeAdapter());
  Hive.registerAdapter(ReadingStatusAdapter());
  Hive.registerAdapter(NotificationSettingsAdapter());
  Hive.registerAdapter(NotificationFrequencyAdapter());
  Hive.registerAdapter(CustomTimeOfDayAdapter());
  Hive.registerAdapter(ChapterProgressAdapter());
  Hive.registerAdapter(ReadingStatisticsAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(ViewModeAdapter());
  Hive.registerAdapter(SortOptionAdapter());
  Hive.registerAdapter(BackupFrequencyAdapter());
  Hive.registerAdapter(ApiConfigurationAdapter());
  Hive.registerAdapter(ApiTypeAdapter());
  Hive.registerAdapter(NotificationPriorityAdapter());
  Hive.registerAdapter(AppColorSchemeAdapter());
  Hive.registerAdapter(ThemeModeAdapter());
}

class OmniReaderApp extends ConsumerWidget {
  const OmniReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettingsAsync = ref.watch(appSettingsProvider);
    final router = ref.watch(routerProvider);

    return appSettingsAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Error initializing app: $error'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(appSettingsProvider),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (settings) => MaterialApp.router(
        title: 'OmniReader',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: AppTheme.lightTheme(settings),
        darkTheme: AppTheme.darkTheme(settings),
        themeMode: settings.themeMode,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: settings.fontSize / 14.0,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
