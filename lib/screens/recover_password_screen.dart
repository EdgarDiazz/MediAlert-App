import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  RecoverPasswordScreenState createState() => RecoverPasswordScreenState();
}

class RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _message = '';

  /// Simula el proceso de recuperación de contraseña
  void _recoverPassword() {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _message = 'Por favor, ingrese su nombre de usuario.';
      });
      return;
    }

    setState(() {
      _message =
          'Si el usuario "$username" está registrado, se enviará un enlace para restablecer la contraseña.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA), 
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.lock_reset, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Recuperar Contraseña',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
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
                      const Icon(Icons.email_outlined,
                          size: 64, color: Colors.teal),
                      const SizedBox(height: 16),
                      Text(
                        'Recuperar tu cuenta',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu nombre de usuario para enviarte instrucciones.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de usuario',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: GoogleFonts.montserrat(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _recoverPassword,
                          icon: const Icon(Icons.send),
                          label: Text(
                            'Enviar enlace',
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
                      const SizedBox(height: 20),
                      if (_message.isNotEmpty)
                        Text(
                          _message,
                          style: GoogleFonts.montserrat(
                            color: Colors.green,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
