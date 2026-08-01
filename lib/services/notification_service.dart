import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Local notification service for hydration reminders.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    await _setLocalTimezone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    _initialized = true;
  }

  /// Resolve the device's IANA timezone (e.g. "Europe/London") and configure
  /// `tz.local`. Falls back to UTC on any failure so scheduling never throws
  /// a "Location not found" error from the timezone package.
  static Future<void> _setLocalTimezone() async {
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e, st) {
      debugPrint('NotificationService: failed to resolve local timezone, '
          'falling back to UTC: $e\n$st');
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Request notification permission (Android 13+ / iOS).
  static Future<void> requestPermissions() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('NotificationService.requestPermissions (android) failed: $e');
    }

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('NotificationService.requestPermissions (ios) failed: $e');
    }
  }

  /// Schedule a recurring reminder every `intervalHours` hours.
  static Future<void> scheduleReminder({
    required int startHour,
    required int intervalHours,
    String title = 'HYDRA',
    String body = 'Time to drink water.',
  }) async {
    try {
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
    } catch (e, st) {
      debugPrint('NotificationService.scheduleReminder failed: $e\n$st');
      rethrow;
    }
  }

  /// Send an immediate notification (e.g. when logging a drink → debt alert).
  static Future<void> showInstant({
    String title = 'HYDRA',
    required String body,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('NotificationService.showInstant failed: $e');
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService.cancelAll failed: $e');
    }
  }
}