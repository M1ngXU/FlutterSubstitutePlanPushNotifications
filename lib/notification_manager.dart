import 'dart:math';
import 'dart:ui';

import 'package:substitute_plan_push_notifications/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static final Random _random = Random();
  static const AndroidBitmap<String> _largeIcon = DrawableResourceAndroidBitmap('@mipmap/ic_app_icon');
  static const Color _color = Color.fromARGB(0, 0x1A, 0xB0, 0x21);

  static init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await _flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_app_icon_foreground'),
        iOS: IOSInitializationSettings()
    ));
  }

  static sendNotification(String title, String content) {
    _flutterLocalNotificationsPlugin.show(
        _random.nextInt(0x7FFFFFFF),
        // android using big text
        title,
        content,
        NotificationDetails(
            android: AndroidNotificationDetails(
                appName,
                'sppn',
                priority: Priority.high,
                color: _color,
                styleInformation: BigTextStyleInformation(content, contentTitle: title),
                largeIcon: _largeIcon,
                importance: Importance.high,
            ),
            iOS: const IOSNotificationDetails()
        )
    );
  }
}