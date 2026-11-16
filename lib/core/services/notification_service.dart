import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wsidappp/features/tasks/domain/entities/task.dart';

/// Central wrapper managing local push notifications and OS permissions:
/// - ID 0: Daily Reminder (recurring daily scheduled notification)
/// - ID 1: Task Timer (scheduled for the end of active task duration)
/// - ID 2: Task Completion (immediate celebration alert)
@lazySingleton
class NotificationService {
  NotificationService(this._prefs)
      : _plugin = FlutterLocalNotificationsPlugin();

  @visibleForTesting
  NotificationService.custom(this._prefs, this._plugin);

  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  static const String _keyFirstLaunchPrompted =
      'has_prompted_notifications_first_launch';
  static const String _keyNotificationsEnabled =
      'app_notifications_enabled';

  static const int dailyReminderId = 0;
  static const int taskTimerId = 1;
  static const int taskCompletedId = 2;

  static const String channelId = 'wsid_notifications';
  static const String channelName = 'What Should I Do Reminders';
  static const String channelDescription =
      'Notifications for daily reminders, active task timers, and celebrations';

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    showWhen: true,
    icon: '@mipmap/ic_launcher',
  );

  static const DarwinNotificationDetails _darwinDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _darwinDetails,
  );

  /// Checks whether notifications are allowed to be scheduled and displayed.
  ///
  /// Returns `true` ONLY IF:
  /// 1. The user enabled notifications in the app settings (`_keyNotificationsEnabled`).
  /// 2. The operating system has granted notification permission.
  Future<bool> areNotificationsEnabled() async {
    final bool userEnabled =
        _prefs.getBool(_keyNotificationsEnabled) ?? false;
    if (!userEnabled) return false;
    return isPermissionGranted();
  }

  /// Checks whether notification permission is actively granted in the OS.
  Future<bool> isPermissionGranted() async {
    final PermissionStatus status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Initializes the notification plugin settings.
  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(channel);
    }

    _isInitialized = true;
  }

  /// Prompts for notification permissions automatically on the very first app launch.
  ///
  /// - If granted: marks app settings toggle ON.
  /// - If denied: marks app settings toggle OFF.
  ///
  /// Subsequent launches will not trigger this automatic prompt.
  Future<bool> checkAndRequestFirstLaunchPermission() async {
    final bool hasPrompted = _prefs.getBool(_keyFirstLaunchPrompted) ?? false;
    if (!hasPrompted) {
      final PermissionStatus status = await Permission.notification.request();
      await _prefs.setBool(_keyFirstLaunchPrompted, true);
      final bool granted = status.isGranted;
      await _prefs.setBool(_keyNotificationsEnabled, granted);
      return granted;
    }
    return areNotificationsEnabled();
  }

  /// Handles user-initiated permission toggle from the Settings/Profile screen.
  ///
  /// - If denied: prompts for permission.
  /// - If permanently denied (or denied again): routes user to the OS settings.
  /// - Returns `true` if permission is granted, otherwise `false`.
  Future<bool> requestPermissionOrOpenSettings() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      status = await Permission.notification.status;
      return status.isGranted;
    }

    if (status.isDenied) {
      status = await Permission.notification.request();
      if (status.isPermanentlyDenied || status.isDenied) {
        await openAppSettings();
        status = await Permission.notification.status;
      }
    }

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        await androidPlugin.requestExactAlarmsPermission();
      } catch (_) {}
    }

    return status.isGranted;
  }

  /// Requests notification and alarm permissions on supported platforms.
  Future<bool> requestPermissions() async {
    bool granted = true;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final bool? notifGranted =
          await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      granted = notifGranted ?? false;
    }

    final iOSPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iOSPlugin != null) {
      final bool? iosGranted = await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = granted && (iosGranted ?? false);
    }

    return granted;
  }

  /// Resolves the optimal Android schedule mode based on device permissions.
  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        final bool? canExact =
            await androidPlugin.canScheduleExactNotifications();
        if (canExact == true) {
          return AndroidScheduleMode.exactAllowWhileIdle;
        }
      } catch (_) {
        // Fallback to inexact mode
      }
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Safely schedules a zoned notification with fallback to inexact timing if exact
  /// alarm permission is not granted by the OS.
  Future<void> _safeZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    final AndroidScheduleMode mode = await _resolveScheduleMode();
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails,
        androidScheduleMode: mode,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      } else {
        rethrow;
      }
    }
  }

  /// Schedules a recurring daily notification at [hour]:[minute].
  /// Default is 09:00 AM.
  ///
  /// If notifications are disabled or permission is missing, cancels any
  /// existing daily reminder and returns immediately.
  Future<void> scheduleDailyReminder({int hour = 9, int minute = 0}) async {
    if (!await areNotificationsEnabled()) {
      await cancelDailyReminder();
      return;
    }

    await init();
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    debugPrint(
      '[NotificationService] Scheduling daily reminder for $hour:${minute.toString().padLeft(2, '0')} at $scheduledDate',
    );

    await _safeZonedSchedule(
      id: dailyReminderId,
      title: 'Daily Task Reminder',
      body:
          'Ready to make progress today? Check your tasks and let the decider pick one for you!',
      scheduledDate: scheduledDate,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedules an alert when the [task]'s duration expires.
  /// (e.g. if estimatedDuration is 30, triggers 30 minutes from now).
  ///
  /// Does nothing if notifications are disabled or permission is missing.
  Future<void> scheduleTaskTimer(Task task) async {
    if (!await areNotificationsEnabled()) return;

    final int? minutes = task.estimatedDuration;
    if (minutes == null || minutes <= 0) return;

    await init();
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

    await _safeZonedSchedule(
      id: taskTimerId,
      title: 'Task Timer',
      body: "Time's up for ${task.title}! Did you finish it?",
      scheduledDate: scheduledDate,
    );
  }

  /// Displays an immediate congratulatory notification upon task completion.
  ///
  /// Does nothing if notifications are disabled or permission is missing.
  Future<void> showTaskCompletedCelebration(Task task) async {
    if (!await areNotificationsEnabled()) return;

    await init();
    await _plugin.show(
      id: taskCompletedId,
      title: 'Task Completed!',
      body: 'Great job completing ${task.title}!',
      notificationDetails: _notificationDetails,
    );
  }

  /// Cancels the scheduled task timer notification (ID 1).
  Future<void> cancelTaskTimer() async {
    await _plugin.cancel(id: taskTimerId);
  }

  /// Cancels the recurring daily reminder notification (ID 0).
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(id: dailyReminderId);
  }

  /// Cancels all notifications across all IDs.
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Computes the next [tz.TZDateTime] for a given [hour] and [minute].
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
