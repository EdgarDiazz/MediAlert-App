// base de datos temporal ficticia
import '../models/medicamento.dart';

class FakeDatabase {
  // Mapa para simular múltiples usuarios. Clave: email/usuario ficticio
  static final Map<String, List<Medicamento>> _data = {};

  static String currentUser = 'usuario@demo.com'; // Usuario por defecto

  // Obtener medicamentos del usuario actual
  static List<Medicamento> get medicamentos {
    return _data[currentUser] ?? [];
  }

  // Agregar medicamento
  static void agregarMedicamento(Medicamento medicamento) {
    if (_data[currentUser] == null) {
      _data[currentUser] = [];
    }
    _data[currentUser]!.add(medicamento);
  }

  // Eliminar medicamento (marcar como eliminado)
  static void eliminarMedicamento(int index) {
    if (_data[currentUser] != null && index < _data[currentUser]!.length) {
      _data[currentUser]![index].eliminado = true;
    }
  }

  // Editar medicamento
  static void editarMedicamento(int index, Medicamento nuevo) {
    if (_data[currentUser] != null && index < _data[currentUser]!.length) {
      _data[currentUser]![index] = nuevo;
    }
  }

  // Cambiar de usuario ficticio
  static void setUsuario(String usuario) {
    currentUser = usuario;
    _data.putIfAbsent(currentUser, () => []);
  }

  // Obtener resumen del estado general (opcional)
  static String obtenerEstadoDesempeno() {
    final meds = medicamentos;
    if (meds.isEmpty) return 'SIN DATOS';
    final activos = meds.where((m) => !m.eliminado).length;
    if (activos >= 3) return 'EXCELENTE';
    if (activos >= 1) return 'BUENO';
    return 'REGULAR';
  }
}