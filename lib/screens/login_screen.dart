import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medialert/screens/main_screen.dart';
import 'register_screen.dart';
import 'recover_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  final Color azulSalud = const Color(0xFF4A90E2); 
  final Color fondo = const Color(0xFFE3F2FD); 

  void _login() async {
    setState(() => isLoading = true);
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final String uid = userCredential.user!.uid;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(userId: uid)),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Usuario no registrado.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else {
        message = 'Error: ${e.message}';
      }
      _showError(message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.medical_services, size: 80, color: Color(0xFF4A90E2)),
              const SizedBox(height: 16),
              Text(
                'MediAlert',
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: azulSalud,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu recordatorio de medicamentos',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // Campo de email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: GoogleFonts.montserrat(),
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Campo de contraseña
              TextField(
                controller: passwordController,
                obscureText: true,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: GoogleFonts.montserrat(),
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Botón de iniciar sesión 
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: Text('Iniciar sesión', style: GoogleFonts.montserrat(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulSalud,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: Text(
                  '¿No tienes cuenta? Regístrate',
                  style: GoogleFonts.montserrat(color: azulSalud, fontSize: 15),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecoverPasswordScreen()),
                ),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: GoogleFonts.montserrat(color: azulSalud, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
