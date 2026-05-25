import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around `flutter_local_notifications` for showing OS-level
/// notifications from in-process events (e.g. a broadcast picked up by the
/// announcements poller).
///
/// Call [init] once at app start. Then call [showBroadcast] with the
/// notification id (any int — stable per broadcast so duplicates collapse),
/// title, and body.
class LocalNotificationsService {
  LocalNotificationsService._();
  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );
    await _plugin.initialize(initSettings);

    // Ask for runtime permission. flutter_local_notifications is a no-op on
    // Android < 13 / iOS where it isn't needed.
    if (!kIsWeb && Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    _initialized = true;
  }

  /// Show a broadcast as a local notification. `id` should be stable per
  /// broadcast (e.g. derived from `Announcement.id`) so re-firing the same
  /// broadcast collapses instead of duplicating.
  Future<void> showBroadcast({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    if (kIsWeb) return;

    const android = AndroidNotificationDetails(
      'goal_connect_broadcasts',
      'Announcements',
      channelDescription:
          'Important announcements from Goal Connect (roster windows, scheduling, etc.).',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'announcement',
    );
    const darwin = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.show(
      id,
      title.isNotEmpty ? title : 'Announcement',
      body,
      details,
    );
  }
}
