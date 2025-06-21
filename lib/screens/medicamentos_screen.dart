import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/add_medicine_screen.dart';

/// Pantalla que muestra la lista de medicamentos registrados por el usuario.
class MedicamentosScreen extends StatelessWidget {
  final String userId;

  const MedicamentosScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final medicamentosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('medicamentos');

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            Text(
              'Medicamentos',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        tooltip: 'Agregar nuevo medicamento',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMedicineScreen(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: medicamentosRef
            .orderBy('fechaCreacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No tienes medicamentos registrados.',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
            );
          }

          final medicamentos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicamentos.length,
            itemBuilder: (context, index) {
              final doc = medicamentos[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  title: Text(
                    data['nombre'] ?? 'Sin nombre',
                    style: GoogleFonts.montserrat(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '💊 Dosis: ${data['dosis']}\n🕒 Hora: ${data['hora']}\n📅 Frecuencia: ${data['frecuencia']}',
                    style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
                  ),
                  trailing: IconButton(
                    tooltip: 'Editar medicamento',
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddMedicineScreen(
                            userId: userId,
                            docId: doc.id,
                            medicamento: data,
                          ),
                        ),
                      );
                    },
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
