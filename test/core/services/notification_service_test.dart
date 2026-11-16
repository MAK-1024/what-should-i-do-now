import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:wsidappp/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('NotificationService', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
    });

    test('areNotificationsEnabled returns false by default when not enabled in prefs', () async {
      final service = NotificationService(prefs);
      final enabled = await service.areNotificationsEnabled();
      expect(enabled, isFalse);
    });

    test('channel configuration constants are properly defined', () {
      expect(NotificationService.channelId, 'wsid_notifications');
      expect(NotificationService.dailyReminderId, 0);
      expect(NotificationService.taskTimerId, 1);
      expect(NotificationService.taskCompletedId, 2);
    });
  });
}
