import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../servicios/servicio_firestore.dart';
import 'add_medicine_screen.dart';
import 'history_screen.dart'; 

/// Pantalla principal que muestra la lista de medicamentos del usuario.
class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    // Estilos de texto
    final TextStyle textoGeneral = GoogleFonts.montserrat(
      fontSize: 18,
      color: Colors.black87,
    );

    final TextStyle textoTitulo = GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    const Color azulSalud = Color(0xFF4A90E2); 
    const Color fondoClaro = Color(0xFFF5F9FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Medicamentos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: azulSalud,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, size: 28),
            tooltip: 'Ver Historial',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: fondoClaro,
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.obtenerMedicamentos(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                '📭 No hay medicamentos registrados.',
                style: textoGeneral,
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final med = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: ListTile(
                    leading: const Icon(Icons.medication_outlined, color: azulSalud, size: 32),
                    title: Text(
                      med['nombre'] ?? 'Medicamento',
                      style: textoTitulo,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '💊 Dosis: ${med['dosis'] ?? '-'}\n⏰ Hora: ${med['hora'] ?? '-'}',
                        style: textoGeneral.copyWith(fontSize: 16),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 26),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddMedicineScreen(
                              userId: userId,
                              docId: docId,
                              medicamento: med,
                            ),
                          ),
                        );
                      },
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMedicineScreen(userId: userId),
            ),
          );
        },
        backgroundColor: azulSalud,
        tooltip: 'Agregar Medicamento',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
