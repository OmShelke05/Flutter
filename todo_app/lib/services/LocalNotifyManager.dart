import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//Local notification configuration and related functions are here.

class LocalNotifyManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initSetting;

  BehaviorSubject<ReceivedNotification>
      get didReceiveLocalNotificationSubject =>
          BehaviorSubject<ReceivedNotification>();

  LocalNotifyManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializePlatform();
    tz.initializeTimeZones();
  }

  initializePlatform() {
    var initSettingAndroid = AndroidInitializationSettings('@drawable/note');
    initSetting = InitializationSettings(android: initSettingAndroid);
  }

  setOnNotificationReceive(Function onNotificationReceive) {
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }

  Future<void> showNotification(currentTask, reminder, index) async {
    var androidChannel = AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME', 'CHANNEL_DESCRIPTION',
        importance: Importance.max, priority: Priority.high, playSound: true);

    var tzReminder = tz.TZDateTime.from(
      reminder.toDate(),
      tz.local,
    );

    var platformChannel = NotificationDetails(android: androidChannel);

    if (tzReminder.isAfter(DateTime.now()))
      await flutterLocalNotificationsPlugin.zonedSchedule(
          index,
          currentTask,
          '',
          tzReminder,
          const NotificationDetails(
              android: AndroidNotificationDetails('your channel id',
                  'your channel name', 'your channel description')),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
  }
}

LocalNotifyManager localNotifyManager = LocalNotifyManager.init();

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}
