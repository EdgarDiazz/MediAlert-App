import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:permission_handler/permission_handler.dart';

/// Plugin principal para notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Canal de notificaciones para medicamentos
const AndroidNotificationChannel canalMedicinas = AndroidNotificationChannel(
  'canal_medicinas', // ID del canal
  'Recordatorios de Medicinas', // Nombre visible
  description: 'Canal para recordar la toma de medicamentos',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

/// Inicializa el sistema de notificaciones
Future<void> initNotificaciones() async {
  try {
    debugPrint('🔧 Iniciando configuración de notificaciones...');
    
    // Inicializa datos de zonas horarias
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));
    debugPrint('✅ Zona horaria configurada: America/Bogota');

    // Solicita permisos de notificación
    await _solicitarPermisos();

    // Configura la inicialización para Android
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    final bool? initialized = await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('📱 Notificación tocada: ${response.payload}');
      },
    );

    debugPrint('✅ Plugin inicializado: $initialized');

    // Crea el canal de notificaciones en Android 8+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canalMedicinas);
    
    debugPrint('✅ Canal de notificaciones creado');

  } catch (e) {
    debugPrint('❌ Error al inicializar notificaciones: $e');
  }
}

/// Solicita permisos necesarios para notificaciones
Future<void> _solicitarPermisos() async {
  try {
    // Solicita permiso de notificaciones (Android 13+)
    final status = await Permission.notification.request();
    debugPrint('📱 Permiso de notificaciones: $status');
    
    debugPrint('✅ Permisos solicitados correctamente');
  } catch (e) {
    debugPrint('❌ Error al solicitar permisos: $e');
  }
}

/// Clase para programar y cancelar notificaciones de medicamentos
class NotificacionHelper {
  /// Programa notificaciones semanales para los días seleccionados
  static Future<void> programarNotificaciones({
    required String nombreMedicamento,
    required TimeOfDay hora,
    required List<int> diasSemana,
  }) async {
    try {
      debugPrint('🚀 Programando notificaciones para: $nombreMedicamento');
      debugPrint('⏰ Hora: ${hora.hour}:${hora.minute}');
      debugPrint('📅 Días: $diasSemana');

      final int baseId = nombreMedicamento.hashCode;

      for (int dia in diasSemana) {
        final int notificationId = baseId + dia;
        debugPrint('✅ Programando: $nombreMedicamento a las ${hora.hour}:${hora.minute} día $dia (ID: $notificationId)');
        
        await agendarNotificacion(
          id: notificationId,
          titulo: 'Hora de tomar tu medicamento',
          mensaje: 'Debes tomar: $nombreMedicamento',
          hour: hora.hour,
          minute: hora.minute,
          dias: [dia],
        );
      }

      debugPrint('✅ Notificaciones programadas exitosamente para $nombreMedicamento');

    } catch (e) {
      debugPrint('❌ Error al programar notificaciones: $e');
    }
  }

  /// Cancela todas las notificaciones de un medicamento
  static Future<void> cancelarNotificaciones({
    required String nombreMedicamento,
    required List<int> diasSemana,
  }) async {
    try {
      final int baseId = nombreMedicamento.hashCode;

      for (int dia in diasSemana) {
        int id = baseId + dia;
        await flutterLocalNotificationsPlugin.cancel(id);
        debugPrint('🛑 Notificación cancelada ID: $id');
      }
      
      debugPrint('✅ Notificaciones canceladas para: $nombreMedicamento');
    } catch (e) {
      debugPrint('❌ Error al cancelar notificaciones: $e');
    }
  }
}

/// Agenda una notificación semanal en los días y hora indicada
Future<void> agendarNotificacion({
  required int id,
  required String titulo,
  required String mensaje,
  required int hour,
  required int minute,
  required List<int> dias,
}) async {
  try {
    for (int dia in dias) {
      final tz.TZDateTime programado = _siguienteFechaProgramada(hour, minute, dia);

      debugPrint('📅 Programando notificación ID $id para: $programado');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        titulo,
        mensaje,
        programado,
        NotificationDetails(
          android: AndroidNotificationDetails(
            canalMedicinas.id,
            canalMedicinas.name,
            channelDescription: canalMedicinas.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF4A90E2),
            enableLights: true,
            ledColor: const Color(0xFF4A90E2),
            ledOnMs: 1000,
            ledOffMs: 500,
            category: AndroidNotificationCategory.reminder,
            actions: [
              const AndroidNotificationAction('tomar', 'Tomar'),
              const AndroidNotificationAction('posponer', 'Posponer 15 min'),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'medicamento_$id',
      );

      debugPrint('✅ Notificación programada exitosamente para ID $id en $programado');
    }
  } catch (e) {
    debugPrint('❌ Error al agendar notificación: $e');
    rethrow;
  }
}

/// Calcula la próxima fecha válida para una notificación semanal
tz.TZDateTime _siguienteFechaProgramada(int hour, int minute, int diaSemana) {
  final now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

  debugPrint('🕐 Calculando fecha para hora $hour:$minute, día $diaSemana');
  debugPrint('🕐 Hora actual: $now');

  while (scheduled.weekday != diaSemana || scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
    debugPrint('🕐 Avanzando a: $scheduled');
  }

  debugPrint('✅ Fecha final calculada: $scheduled');
  return scheduled;
}
