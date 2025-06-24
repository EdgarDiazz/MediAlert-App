import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servicios/servicio_auth.dart';

/// Pantalla de perfil del usuario
class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _displayName;
  String? _email;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _displayName = user?.displayName;
      _email = user?.email;
    });
  }

  /// Método para cerrar sesión y limpiar datos locales
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('medicamentos_${widget.userId}');
    await prefs.remove('username');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
            const CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage('assets/logo.png'),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              _displayName != null && _displayName!.isNotEmpty
                  ? _displayName!
                  : (_email ?? widget.userId),
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '¡Bienvenido!',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: Colors.teal[600],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usuario:',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.teal[900])),
                    const SizedBox(height: 4),
                    Text(
                      _email ?? widget.userId,
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text('Rol:',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.teal[900])),
                    const SizedBox(height: 4),
                    Text('Paciente', style: GoogleFonts.montserrat(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Futuro: editar perfil
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.montserrat(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.montserrat(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 32),
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
