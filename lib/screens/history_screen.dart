import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../servicios/servicio_firestore.dart';

/// Pantalla para mostrar el historial de medicamentos de un usuario.
class HistoryScreen extends StatelessWidget {
  final String userId;

  // Servicio Firestore para obtener los medicamentos
  final FirestoreService _firestoreService = FirestoreService();

  HistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Definir estilo de texto general
    final TextStyle textoGeneral = GoogleFonts.montserrat(
      fontSize: 18,
      color: Colors.black87,
    );

    final TextStyle textoTitulo = GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    // Color principal azul suave
    const Color azulSalud = Color(0xFF4A90E2);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Medicamentos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: azulSalud,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F9FF), 
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.obtenerMedicamentos(userId),
        builder: (context, snapshot) {
          // Error al obtener los datos
          if (snapshot.hasError) {
            return Center(
              child: Text('❌ Error al cargar el historial', style: textoGeneral),
            );
          }

          // Mientras se cargan los datos
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Si no hay medicamentos guardados
          if (docs.isEmpty) {
            return Center(
              child: Text(
                '📭 No hay medicamentos en el historial.',
                style: textoGeneral.copyWith(fontSize: 16),
              ),
            );
          }

          // Lista de medicamentos en tarjetas
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícono de medicina
                      const Icon(Icons.medication_liquid, size: 36, color: azulSalud),
                      const SizedBox(width: 16),

                      // Contenido del medicamento
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nombre'] ?? 'Medicamento sin nombre',
                              style: textoTitulo,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '💊 Dosis: ${data['dosis'] ?? '-'}',
                              style: textoGeneral,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '⏰ Hora: ${data['hora'] ?? '-'}',
                              style: textoGeneral,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
