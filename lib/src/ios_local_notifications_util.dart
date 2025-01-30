import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class IosLocalNotificationsUtil {
  IosLocalNotificationsUtil() {
    initialize();
  }

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings(//any of them true for request notification permission
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: true,
    );

    InitializationSettings settings =
        InitializationSettings(iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse);
  }

  showNotification({required int id, String? title, required String body}) {
    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(iOS: DarwinNotificationDetails(
        presentAlert: false,//disable foreground
        presentBanner: false//disable foreground
      )),
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
