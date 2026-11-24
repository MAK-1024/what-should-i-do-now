import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsidappp/core/services/notification_service.dart';
import 'package:wsidappp/core/settings/app_settings_cubit.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';

class _FakeNotificationService implements NotificationService {
  _FakeNotificationService({this.grantPermission = true});

  final bool grantPermission;
  int dailyRemindersScheduled = 0;
  int lastReminderHour = -1;
  int lastReminderMinute = -1;
  int allCancelled = 0;
  int dailyCancelled = 0;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermissions() async => grantPermission;

  @override
  Future<bool> checkAndRequestFirstLaunchPermission() async => grantPermission;

  @override
  Future<bool> areNotificationsEnabled() async => grantPermission;

  @override
  Future<bool> isPermissionGranted() async => grantPermission;

  @override
  Future<void> cancelDailyReminder() async {
    dailyCancelled++;
  }

  @override
  Future<bool> requestPermissionOrOpenSettings() async => grantPermission;

  @override
  Future<void> scheduleDailyReminder({int hour = 9, int minute = 0}) async {
    dailyRemindersScheduled++;
    lastReminderHour = hour;
    lastReminderMinute = minute;
  }

  @override
  Future<void> scheduleTaskTimer(Task task, {int? durationMinutes}) async {}

  @override
  Future<void> showTaskCompletedCelebration(Task task) async {}

  @override
  Future<void> cancelTaskTimer() async {}

  @override
  Future<void> cancelAllNotifications() async {
    allCancelled++;
  }

  @override
  Future<void> completeFirstLaunchPermissionPrompt({required bool userWantsNotifications}) {
    // TODO: implement completeFirstLaunchPermissionPrompt
    throw UnimplementedError();
  }

  @override
  bool shouldPromptFirstLaunchPermission() {
    // TODO: implement shouldPromptFirstLaunchPermission
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  group('AppSettingsCubit toggleNotifications', () {
    test('enabling notifications when permission is granted updates state and schedules reminder with custom time', () async {
      final notifService = _FakeNotificationService(grantPermission: true);
      final cubit = AppSettingsCubit(prefs, notifService);

      await cubit.updateReminderTime(8, 30);
      await cubit.toggleNotifications(true);

      expect(cubit.state.notificationsEnabled, isTrue);
      expect(notifService.dailyRemindersScheduled, 1);
      expect(notifService.lastReminderHour, 8);
      expect(notifService.lastReminderMinute, 30);
      expect(prefs.getBool('app_notifications_enabled'), isTrue);
    });

    test('enabling notifications when permission is denied remains false and does not schedule', () async {
      final notifService = _FakeNotificationService(grantPermission: false);
      final cubit = AppSettingsCubit(prefs, notifService);

      await cubit.toggleNotifications(true);

      expect(cubit.state.notificationsEnabled, isFalse);
      expect(notifService.dailyRemindersScheduled, 0);
      expect(prefs.getBool('app_notifications_enabled'), isFalse);
    });

    test('disabling notifications updates state and cancels all notifications', () async {
      final notifService = _FakeNotificationService(grantPermission: true);
      final cubit = AppSettingsCubit(prefs, notifService);

      await cubit.toggleNotifications(false);

      expect(cubit.state.notificationsEnabled, isFalse);
      expect(notifService.allCancelled, 1);
      expect(prefs.getBool('app_notifications_enabled'), isFalse);
    });
  });

  group('AppSettingsCubit updateReminderTime', () {
    test('updates state, persists to prefs, and reschedules if notifications enabled', () async {
      final notifService = _FakeNotificationService(grantPermission: true);
      final cubit = AppSettingsCubit(prefs, notifService);

      await cubit.toggleNotifications(true);
      expect(notifService.dailyRemindersScheduled, 1);

      await cubit.updateReminderTime(14, 45);

      expect(cubit.state.reminderHour, 14);
      expect(cubit.state.reminderMinute, 45);
      expect(prefs.getInt('app_reminder_hour'), 14);
      expect(prefs.getInt('app_reminder_minute'), 45);
      expect(notifService.dailyCancelled, 1);
      expect(notifService.dailyRemindersScheduled, 2);
      expect(notifService.lastReminderHour, 14);
      expect(notifService.lastReminderMinute, 45);
    });

    test('loadSettings restores saved reminder hour and minute', () async {
      await prefs.setInt('app_reminder_hour', 10);
      await prefs.setInt('app_reminder_minute', 15);

      final notifService = _FakeNotificationService(grantPermission: false);
      final cubit = AppSettingsCubit(prefs, notifService);

      await cubit.loadSettings();

      expect(cubit.state.reminderHour, 10);
      expect(cubit.state.reminderMinute, 15);
    });
  });
}
