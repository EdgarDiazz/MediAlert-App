import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/fake_database.dart';
import '../models/medicamento.dart';

/// Pantalla que muestra un resumen del usuario: estado de desempeño y medicamentos eliminados
class UserSummaryScreen extends StatelessWidget {
  const UserSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = FakeDatabase.obtenerEstadoDesempeno();
    final eliminados = FakeDatabase.medicamentos.where((m) => m.eliminado).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF8), 
      appBar: AppBar(
        title: const Text('Resumen de Usuario'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(
              'Estado actual:',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                estado,
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),

            // Título de medicamentos eliminados
            Text(
              'Medicamentos eliminados',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Lista o mensaje en caso de que no existan
            eliminados.isEmpty
                ? Text(
                    'No hay medicamentos eliminados.',
                    style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black54),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: eliminados.length,
                      itemBuilder: (context, index) {
                        final med = eliminados[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                            title: Text(
                              med.nombre ?? 'Sin nombre',
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              med.estado ?? 'Sin estado',
                              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
