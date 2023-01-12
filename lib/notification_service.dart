import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    static final NotificationService _notificationService =
    NotificationService._internal();

    factory NotificationService() {
        return _notificationService;
    }

    NotificationService._internal();

    Future<void> init() async {
        final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  
        final InitializationSettings initializationSettings =
            InitializationSettings(
                android: initializationSettingsAndroid, 
            );

        await flutterLocalNotificationsPlugin.initialize(initializationSettings,
                onSelectNotification: selectNotification);
    }
    FlutterLocalNotificationsPlugin getFlnp() {
        return flutterLocalNotificationsPlugin;
    }

    Future<void> selectNotification(String? payload) async {

    }
}
