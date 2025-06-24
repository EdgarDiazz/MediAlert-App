import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/add_medicine_screen.dart';
import '../screens/main_screen.dart';
import '../helpers/notificacion_helper.dart';

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
      backgroundColor: const Color(0xFFF0FAF8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Mis Medicamentos',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        tooltip: 'Agregar nuevo medicamento',
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMedicineScreen(userId: userId),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: medicamentosRef.orderBy('fechaCreacion', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hay medicamentos registrados.',
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

              // Convertir días (int) a texto
              final diasSemana = (data['diasSemana'] as List<dynamic>? ?? [])
                  .cast<int>()
                  .map((d) => _nombreDia(d))
                  .join(', ');

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  title: Text(
                    data['nombre'] ?? 'Sin nombre',
                    style: GoogleFonts.montserrat(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '💊 Dosis: ${data['dosis']}\n'
                    '🕒 Hora: ${data['hora']}\n'
                    '📅 Días: $diasSemana',
                    style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
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
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Medicamento'),
                              content: const Text('¿Estás seguro de eliminar este medicamento?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await NotificacionHelper.cancelarNotificaciones(
                                nombreMedicamento: data['nombre'],
                                diasSemana: List<int>.from(data['diasSemana'] ?? []),
                              );

                              await medicamentosRef.doc(doc.id).delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Medicamento eliminado'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MainScreen(userId: userId),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al eliminar: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
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

  /// Traduce el número del día a nombre corto en español
  String _nombreDia(int numeroDia) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    if (numeroDia >= 1 && numeroDia <= 7) return dias[numeroDia - 1];
    return 'Desconocido';
  }
}
