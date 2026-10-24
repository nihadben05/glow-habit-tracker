import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    await _plugin.initialize(const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ));

    tz.initializeTimeZones();
    final localTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone));
  }

  int _baseId(String habitId) => habitId.hashCode & 0x7fffffff;

  int _notificationId(String habitId, int offset) {
    return (_baseId(habitId) % 1000000) * 10 + offset;
  }

  List<int> _allHabitNotificationIds(String habitId) {
    return List<int>.generate(10, (index) => _notificationId(habitId, index + 1));
  }

  List<int> _weekdayNumbers(String freq) {
    switch (freq) {
      case 'weekdays':
        return [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday];
      case 'weekends':
        return [DateTime.saturday, DateTime.sunday];
      case '3x_week':
        return [DateTime.monday, DateTime.wednesday, DateTime.friday];
      default:
        return [];
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(int weekday, int hour, int minute) {
    var scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _scheduleDaily(int id, String title, String body, int hour, int minute) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit reminders',
          channelDescription: 'Daily habit reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeekly(int id, String title, String body, int weekday, int hour, int minute) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeekdayAndTime(weekday, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit reminders',
          channelDescription: 'Weekly habit reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleHabitReminder({
    required String habitId,
    required String title,
    required String body,
    required String reminderTime,
    required String freq,
  }) async {
    await cancelHabitReminders(habitId);

    if (reminderTime.isEmpty) {
      return;
    }

    final parts = reminderTime.split(':');
    if (parts.length != 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final weekdayNumbers = _weekdayNumbers(freq);
    if (weekdayNumbers.isEmpty) {
      await _scheduleDaily(_notificationId(habitId, 1), title, body, hour, minute);
      return;
    }

    for (var i = 0; i < weekdayNumbers.length; i++) {
      await _scheduleWeekly(
        _notificationId(habitId, i + 1),
        title,
        body,
        weekdayNumbers[i],
        hour,
        minute,
      );
    }
  }

  Future<void> cancelHabitReminders(String habitId) async {
    final ids = _allHabitNotificationIds(habitId);
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
