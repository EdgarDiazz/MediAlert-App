import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla para restablecer la contraseña mediante correo
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF8), 
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: const [
            Icon(Icons.lock_reset),
            SizedBox(width: 8),
            Text('Recuperar Contraseña'),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.teal),
                const SizedBox(height: 16),
                Text(
                  'Restablece tu contraseña',
                  style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Introduce tu correo electrónico y te enviaremos instrucciones.',
                  style: GoogleFonts.montserrat(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final email = emailController.text.trim();
                      if (email.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Si "$email" está registrado, se enviarán instrucciones.',
                              style: GoogleFonts.montserrat(fontSize: 16),
                            ),
                            backgroundColor: Colors.teal,
                          ),
                        );
                        Navigator.pop(context); // Regresa al login u otra pantalla
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Por favor, ingresa un correo válido.',
                              style: GoogleFonts.montserrat(fontSize: 16),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: Text(
                      'ENVIAR INSTRUCCIONES',
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
