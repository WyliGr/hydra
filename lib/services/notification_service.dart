import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Local notification service for hydration reminders.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Request notification permission (Android 13+ / iOS).
  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedule a recurring reminder every `intervalHours` hours.
  static Future<void> scheduleReminder({
    required int startHour,
    required int intervalHours,
    String title = 'HYDRA',
    String body = 'Time to drink water.',
  }) async {
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    var nextTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      startHour,
    );

    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(Duration(hours: intervalHours));
    }

    int id = 0;
    while (nextTime.hour < 23) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        nextTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
   'hydra_reminders',
   'Hydra Reminders',
   icon: '@mipmap/ic_launcher',
   importance: Importance.defaultImportance,
 ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      id++;
      nextTime = nextTime.add(Duration(hours: intervalHours));
    }
  }

  /// Send an immediate notification (e.g. when logging a drink → debt alert).
  static Future<void> showInstant({
    String title = 'HYDRA',
    required String body,
  }) async {
    await _plugin.show(
      999,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
   'hydra_alerts',
   'Hydra Alerts',
   icon: '@mipmap/ic_launcher',
   importance: Importance.high,
 ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}