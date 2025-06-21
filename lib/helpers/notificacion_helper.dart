// helpers/notificacion_helper.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotificaciones() async {
  tzdata.initializeTimeZones();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

// Agenda una notificación diaria a una hora específica y con un ID único
Future<void> agendarNotificacion({
  required int id,
  required String titulo,
  required String mensaje,
  required int hour,
  required int minute,
  required List<int> dias,
}) async {
  for (var dia in dias) {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id + dia, // ID único por día
      titulo,
      mensaje,
      _siguienteFechaProgramada(hour, minute, dia),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_medicinas',
          'Recordatorios de Medicinas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

// Obtiene la siguiente fecha programada según el día de la semana
tz.TZDateTime _siguienteFechaProgramada(int hour, int minute, int diaSemana) {
  final now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  while (scheduled.weekday != diaSemana || scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
