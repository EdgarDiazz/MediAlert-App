import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'helpers/notificacion_helper.dart'; // Inicializador de notificaciones locales
import 'screens/login_screen.dart';

/// Maneja mensajes recibidos cuando la app está en segundo plano o cerrada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📥 [BG] Mensaje recibido: ${message.notification?.title}');
}

/// Punto de entrada de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  // Inicializa zonas horarias para notificaciones locales
  tz.initializeTimeZones();
  

  // Inicializa servicio de notificaciones locales
  await initNotificaciones();

  // Maneja mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicia la app
  runApp(const MediAlertApp());
}

/// Widget raíz de la aplicación
class MediAlertApp extends StatefulWidget {
  const MediAlertApp({super.key});

  @override
  State<MediAlertApp> createState() => _MediAlertAppState();
}

class _MediAlertAppState extends State<MediAlertApp> {
  @override
  void initState() {
    super.initState();
    _configurarFirebaseMessaging();
  }

  /// Configura Firebase Messaging: permisos, listeners y token
  Future<void> _configurarFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicita permisos (Android 13+)
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Permiso de notificaciones autorizado');

      // Obtiene el token del dispositivo
      final token = await messaging.getToken();
      debugPrint('📲 Token FCM: $token');

      // Escucha mensajes cuando la app está en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📩 Notificación en foreground: ${message.notification?.title}');
        // Puedes mostrar notificaciones locales si deseas
        
      });

      // Cuando el usuario toca una notificación y abre la app
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📬 Notificación abierta por el usuario');
        // Puedes navegar a otra pantalla
      });
    } else {
      debugPrint('❌ Permiso de notificaciones denegado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediAlert',
      debugShowCheckedModeBanner: false,

      // Tema visual general de la app
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF0FAF8),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),

      // Pantalla inicial
      home: const LoginScreen(),
    );
  }
}
