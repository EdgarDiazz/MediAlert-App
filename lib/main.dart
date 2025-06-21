import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'helpers/notificacion_helper.dart'; // Inicializador de notificaciones
import 'screens/login_screen.dart';

/// Punto de entrada de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con configuración generada automáticamente
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa zonas horarias para notificaciones programadas
  tz.initializeTimeZones();

  // Inicializa servicio de notificaciones local
  await initNotificaciones();

  // Inicia la app
  runApp(const MediAlertApp());
}

/// Widget raíz de la aplicación
class MediAlertApp extends StatelessWidget {
  const MediAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediAlert',
      debugShowCheckedModeBanner: false,

      // Tema visual general de la app
      theme: ThemeData(
        primarySwatch: Colors.teal, // Color base
        scaffoldBackgroundColor: const Color(0xFFF0FAF8), // Fondo claro tipo salud

        // Estilo para AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),

        // Estilo para botones elevados
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

        // Estilo para campos de texto
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

      // Pantalla de inicio
      home: const LoginScreen(),
    );
  }
}
