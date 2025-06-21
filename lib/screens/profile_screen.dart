import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

/// Pantalla de perfil del usuario
class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  /// Método para cerrar sesión y limpiar datos locales
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('medicamentos_$userId');
    await prefs.remove('username');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA), 
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 165, 241),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar del perfil
            const CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage('assets/logo.png'), 
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),

            Text(
              '¡Bienvenido!',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),

            const SizedBox(height: 24),

            // Tarjeta con información del perfil
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario:',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.teal[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userId,
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rol:',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.teal[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paciente',
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botón editar perfil
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // En el futuro puedes redirigir a pantalla de edición
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.montserrat(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón cerrar sesión
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.montserrat(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Frase 
            Text(
              '"Tu salud es tu mayor tesoro. ¡Cuídala!"',
              style: GoogleFonts.montserrat(
                fontStyle: FontStyle.italic,
                color: Colors.teal[800],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
