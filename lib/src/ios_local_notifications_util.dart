import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class IosLocalNotificationsUtil {
  IosLocalNotificationsUtil() {
    initialize();
  }

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    InitializationSettings settings =
        InitializationSettings(iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse);
  }

  showNotification({required id, String? title, required String body}) {
    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(iOS: DarwinNotificationDetails()),
    );
  }

  cancelNotification(int id) {
    flutterLocalNotificationsPlugin.cancel(id);
  }

  cancelAllNotifications() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  static onDidReceiveNotificationResponse(NotificationResponse details) {}

  static onDidReceiveBackgroundNotificationResponse(
      NotificationResponse details) {}
}
