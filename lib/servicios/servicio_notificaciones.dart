import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Servicio para manejar notificaciones programadas en la app
class NotificacionesServicio {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio de notificaciones
  static Future<void> inicializar() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  /// 🔁 Programar notificación recurrente semanal
  static Future<void> programarNotificacionRecurrente({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaHora,
    required Day diaSemana,
  }) async {
    tz.initializeTimeZones();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Construir la fecha programada con la hora seleccionada
    tz.TZDateTime programado = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      fechaHora.hour,
      fechaHora.minute,
    );

    // Avanza hasta que sea el día de la semana correcto
    while (programado.weekday != _dayToWeekday(diaSemana)) {
      programado = programado.add(const Duration(days: 1));
    }

    // Si ese día y hora ya pasó, ve a la siguiente semana
    if (programado.isBefore(now)) {
      programado = programado.add(const Duration(days: 7));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      programado,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicamentos_channel_id',
          'Recordatorios de Medicamentos',
          channelDescription: 'Notificaciones para tomar tus medicamentos',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ actualizado
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  /// 💡 Notificación única (para pruebas inmediatas)
  static Future<void> programarNotificacionUnica({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaHora,
  }) async {
    tz.initializeTimeZones();
    final tz.TZDateTime programado = tz.TZDateTime.from(fechaHora, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      programado,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'unico_channel',
          'Notificación única',
          channelDescription: 'Notificación para pruebas inmediatas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ actualizado
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  /// Convierte un enum Day a número de día de la semana (1=Lunes, ..., 7=Domingo)
  static int _dayToWeekday(Day day) {
    switch (day) {
      case Day.monday:
        return DateTime.monday;
      case Day.tuesday:
        return DateTime.tuesday;
      case Day.wednesday:
        return DateTime.wednesday;
      case Day.thursday:
        return DateTime.thursday;
      case Day.friday:
        return DateTime.friday;
      case Day.saturday:
        return DateTime.saturday;
      case Day.sunday:
        return DateTime.sunday;
    }
  }
}
