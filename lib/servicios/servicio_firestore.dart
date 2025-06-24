import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Agrega un nuevo medicamento al usuario
  Future<void> agregarMedicamento(String userId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('usuarios')
          .doc(userId)
          .collection('medicamentos')
          .add(data);
    } catch (e) {
      print('❌ Error al agregar medicamento: $e');
      rethrow;
    }
  }

  /// Elimina un medicamento según su ID y el usuario
  Future<void> eliminarMedicamento(String userId, String docId) async {
    try {
      await _db
          .collection('usuarios')
          .doc(userId)
          .collection('medicamentos')
          .doc(docId)
          .delete();
    } catch (e) {
      print('❌ Error al eliminar medicamento: $e');
      rethrow;
    }
  }

  /// Actualiza un medicamento específico
  Future<void> actualizarMedicamento(String userId, String docId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('usuarios')
          .doc(userId)
          .collection('medicamentos')
          .doc(docId)
          .update(data);
    } catch (e) {
      print('❌ Error al actualizar medicamento: $e');
      rethrow;
    }
  }

  /// Escucha en tiempo real los medicamentos del usuario
  Stream<QuerySnapshot> obtenerMedicamentos(String userId) {
    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('medicamentos')
        .snapshots();
  }
}
