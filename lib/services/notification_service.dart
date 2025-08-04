import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reading_item.dart';
import '../models/app_settings.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static const String _channelId = 'omnireader_notifications';
  static const String _channelName = 'OmniReader Notifications';
  static const String _channelDescription = 'Notifications for reading reminders and updates';

  static const String _readingReminderChannelId = 'reading_reminders';
  static const String _updateChannelId = 'update_notifications';
  static const String _achievementChannelId = 'achievements';

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: _readingReminderChannelId,
          channelName: 'Reading Reminders',
          channelDescription: 'Reminders to continue reading your favorite series',
          defaultColor: const Color(0xFF6366F1),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: _updateChannelId,
          channelName: 'Update Notifications',
          channelDescription: 'Notifications about new chapters and updates',
          defaultColor: const Color(0xFFEC4899),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: _achievementChannelId,
          channelName: 'Achievements',
          channelDescription: 'Reading achievements and milestones',
          defaultColor: const Color(0xFFF59E0B),
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
          playSound: true,
          enableVibration: false,
        ),
      ],
    );

    // Initialize Flutter Local Notifications (fallback)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Initialize WorkManager for background tasks
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    _isInitialized = true;
  }

  static Future<bool> requestPermission() async {
    final service = NotificationService();
    return await service.requestPermissions();
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<bool> requestPermissions() async {
    // Request notification permissions
    final notificationStatus = await Permission.notification.request();

    // Request Awesome Notifications permissions
    final awesomePermission = await AwesomeNotifications().isNotificationAllowed();
    if (!awesomePermission) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Request exact alarm permission for Android 12+
    if (Platform.isAndroid) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      return notificationStatus.isGranted && alarmStatus.isGranted;
    }

    return notificationStatus.isGranted;
  }

  Future<bool> areNotificationsEnabled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Reading reminder notifications
  Future<void> scheduleReadingReminder(ReadingItem item) async {
    if (!_isInitialized) await initialize();

    final settings = item.notificationSettings;
    if (settings == null || !settings.enabled) return;

    await cancelReadingReminder(item.id);

    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      settings.reminderTime.hour,
      settings.reminderTime.minute,
    );

    // If the time has passed today, schedule for tomorrow
    final scheduledTime = reminderTime.isBefore(now)
        ? reminderTime.add(const Duration(days: 1))
        : reminderTime;

    switch (settings.frequency) {
      case NotificationFrequency.daily:
        await _scheduleDailyReminder(item, scheduledTime, settings);
        break;
      case NotificationFrequency.weekly:
        await _scheduleWeeklyReminder(item, scheduledTime, settings);
        break;
      case NotificationFrequency.monthly:
        await _scheduleMonthlyReminder(item, scheduledTime, settings);
        break;
      case NotificationFrequency.custom:
        await _scheduleCustomReminder(item, scheduledTime, settings);
        break;
    }
  }

  Future<void> _scheduleDailyReminder(
    ReadingItem item,
    DateTime scheduledTime,
    NotificationSettings settings,
  ) async {
    final notificationId = _getNotificationId(item.id);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: _readingReminderChannelId,
        title: 'Time to read ${item.title}!',
        body: settings.customMessage ??
               'Continue your journey with ${item.title}. You\'re on chapter ${item.currentChapter}.',
        bigPicture: item.localCoverPath,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'type': 'reading_reminder',
          'itemId': item.id,
          'action': 'open_item',
        },
      ),
      schedule: NotificationCalendar(
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> _scheduleWeeklyReminder(
    ReadingItem item,
    DateTime scheduledTime,
    NotificationSettings settings,
  ) async {
    for (final dayOfWeek in settings.reminderDays) {
      final notificationId = _getNotificationId('${item.id}_$dayOfWeek');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: _readingReminderChannelId,
          title: 'Weekly reading reminder: ${item.title}',
          body: settings.customMessage ??
                 'Don\'t forget to catch up with ${item.title}!',
          bigPicture: item.localCoverPath,
          notificationLayout: NotificationLayout.BigPicture,
          payload: {
            'type': 'reading_reminder',
            'itemId': item.id,
            'action': 'open_item',
          },
        ),
        schedule: NotificationCalendar(
          weekday: dayOfWeek,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
          second: 0,
          repeats: true,
        ),
      );
    }
  }

  Future<void> _scheduleMonthlyReminder(
    ReadingItem item,
    DateTime scheduledTime,
    NotificationSettings settings,
  ) async {
    final notificationId = _getNotificationId(item.id);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: _readingReminderChannelId,
        title: 'Monthly check-in: ${item.title}',
        body: settings.customMessage ??
               'How\'s your progress with ${item.title}? Time for an update!',
        bigPicture: item.localCoverPath,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'type': 'reading_reminder',
          'itemId': item.id,
          'action': 'open_item',
        },
      ),
      schedule: NotificationCalendar(
        day: scheduledTime.day,
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> _scheduleCustomReminder(
    ReadingItem item,
    DateTime scheduledTime,
    NotificationSettings settings,
  ) async {
    // Custom frequency logic can be implemented here
    // For now, fallback to daily
    await _scheduleDailyReminder(item, scheduledTime, settings);
  }

  Future<void> cancelReadingReminder(String itemId) async {
    final notificationId = _getNotificationId(itemId);
    await AwesomeNotifications().cancel(notificationId);

    // Cancel weekly reminders for all days
    for (int day = 1; day <= 7; day++) {
      final weeklyId = _getNotificationId('${itemId}_$day');
      await AwesomeNotifications().cancel(weeklyId);
    }
  }

  // Update notifications
  Future<void> showNewChapterNotification({
    required String itemId,
    required String title,
    required int newChapter,
    String? coverImagePath,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationId = _getNotificationId('update_$itemId');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: _updateChannelId,
        title: 'New chapter available!',
        body: '$title - Chapter $newChapter is now available',
        bigPicture: coverImagePath,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'type': 'new_chapter',
          'itemId': itemId,
          'chapter': newChapter.toString(),
          'action': 'open_item',
        },
      ),
    );
  }

  Future<void> showSeriesCompletedNotification({
    required String itemId,
    required String title,
    String? coverImagePath,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationId = _getNotificationId('completed_$itemId');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: _updateChannelId,
        title: 'Series completed! 🎉',
        body: 'Congratulations! You\'ve finished reading $title',
        bigPicture: coverImagePath,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'type': 'series_completed',
          'itemId': itemId,
          'action': 'open_item',
        },
      ),
    );
  }

  // Achievement notifications
  Future<void> showAchievementNotification({
    required String title,
    required String description,
    String? iconPath,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationId = DateTime.now().millisecondsSinceEpoch;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: _achievementChannelId,
        title: 'Achievement Unlocked! 🏆',
        body: '$title - $description',
        largeIcon: iconPath,
        notificationLayout: NotificationLayout.BigText,
        payload: {
          'type': 'achievement',
          'action': 'open_achievements',
        },
      ),
    );
  }

  Future<void> showReadingStreakNotification(int streakDays) async {
    await showAchievementNotification(
      title: '$streakDays Day Reading Streak!',
      description: 'Keep up the great reading habit!',
    );
  }

  Future<void> showMilestoneNotification({
    required String milestone,
    required String description,
  }) async {
    await showAchievementNotification(
      title: milestone,
      description: description,
    );
  }

  // Background task notifications
  Future<void> scheduleBackgroundCheck() async {
    await Workmanager().registerPeriodicTask(
      'background_check',
      'backgroundCheck',
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  Future<void> cancelBackgroundCheck() async {
    await Workmanager().cancelByUniqueName('background_check');
  }

  // Notification management
  Future<List<NotificationModel>> getActiveNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> cancelNotificationsByType(String type) async {
    final notifications = await getActiveNotifications();
    for (final notification in notifications) {
      final payload = notification.content?.payload;
      if (payload != null && payload['type'] == type) {
        await AwesomeNotifications().cancel(notification.content!.id!);
      }
    }
  }

  // Utility methods
  int _getNotificationId(String identifier) {
    return identifier.hashCode.abs() % 2147483647; // Ensure positive 32-bit int
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = json.decode(payload);
      _handleNotificationAction(data);
    }
  }

  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final action = data['action'] as String?;
    final itemId = data['itemId'] as String?;

    switch (type) {
      case 'reading_reminder':
      case 'new_chapter':
      case 'series_completed':
        if (action == 'open_item' && itemId != null) {
          // Navigate to item details
          // This would be handled by the app's navigation system
        }
        break;
      case 'achievement':
        if (action == 'open_achievements') {
          // Navigate to achievements screen
        }
        break;
    }
  }

  // Settings management
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    // Update global notification settings
    // This would typically be stored in shared preferences or database
  }

  Future<void> testNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch,
        channelKey: _readingReminderChannelId,
        title: 'Test Notification',
        body: 'This is a test notification from OmniReader',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // Cleanup
  Future<void> dispose() async {
    await cancelAllNotifications();
    await Workmanager().cancelAll();
  }
}

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'backgroundCheck':
        // Perform background checks for new chapters, updates, etc.
        await _performBackgroundCheck();
        break;
    }
    return Future.value(true);
  });
}

Future<void> _performBackgroundCheck() async {
  // This would check for new chapters, updates, etc.
  // and send notifications accordingly

  try {
    // Example: Check for new chapters from APIs
    // Send notifications for any updates found

    print('Background check completed');
  } catch (e) {
    print('Background check failed: $e');
  }
}
