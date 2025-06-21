import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Instancia global del plugin de notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificacionHelper {
  /// Programa notificaciones recurrentes en días específicos de la semana a una hora determinada.
  ///
  /// - [idBase]: Identificador base para evitar colisiones (se suma con el día de la semana).
  /// - [titulo]: Título de la notificación.
  /// - [cuerpo]: Cuerpo de la notificación.
  /// - [hora]: Hora exacta en que se debe enviar la notificación.
  /// - [diasSemana]: Lista de días (1=Lunes ... 7=Domingo) en que debe repetirse.
  static Future<void> programarNotificacion({
    required int idBase,
    required String titulo,
    required String cuerpo,
    required TimeOfDay hora,
    required List<int> diasSemana,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'canal_medicamentos', // ID del canal
      'Medicamentos', // Nombre del canal
      channelDescription: 'Recordatorio de medicamentos',
      importance: Importance.max,
      priority: Priority.high,
    );

    final detalles = NotificationDetails(android: androidDetails);
    final ahora = tz.TZDateTime.now(tz.local);

    for (var dia in diasSemana) {
      final dayDiff = (dia - ahora.weekday + 7) % 7;

      var programado = tz.TZDateTime(
        tz.local,
        ahora.year,
        ahora.month,
        ahora.day,
        hora.hour,
        hora.minute,
      ).add(Duration(days: dayDiff));

      // Si la hora ya pasó hoy, se agenda para la próxima semana
      if (programado.isBefore(ahora)) {
        programado = programado.add(const Duration(days: 7));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        idBase + dia, // ID único combinando base + día
        titulo,
        cuerpo,
        programado,
        detalles,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Cancela una lista de notificaciones según sus identificadores
  static Future<void> cancelarNotificaciones(List<int> ids) async {
    for (var id in ids) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
  }
}
