import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

class StorageService {
  static const String _keyMedicamentos = 'medicamentos';

  // Obtener lista de medicamentos almacenados
  static Future<List<Medicine>> obtenerMedicamentos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMedicamentos);
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString);
    return decoded.map((e) => Medicine.fromJson(e)).toList();
  }

  // Guardar un medicamento (añadir o reemplazar si el ID ya existe)
  static Future<void> guardarMedicamento(Medicine med) async {
    final lista = await obtenerMedicamentos();
    final index = lista.indexWhere((m) => m.id == med.id);
    if (index != -1) {
      lista[index] = med;
    } else {
      lista.add(med);
    }
    await _guardarLista(lista);
  }

  // Eliminar medicamento por índice
  static Future<void> eliminarMedicamento(int index) async {
    final lista = await obtenerMedicamentos();
    if (index >= 0 && index < lista.length) {
      lista.removeAt(index);
      await _guardarLista(lista);
    }
  }

  // Reemplazar toda la lista
  static Future<void> _guardarLista(List<Medicine> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(lista.map((e) => e.toJson()).toList());
    await prefs.setString(_keyMedicamentos, jsonString);
  }

  // Editar un medicamento (por ID)
  static Future<void> editarMedicamento(Medicine medActualizado) async {
    final lista = await obtenerMedicamentos();
    final index = lista.indexWhere((m) => m.id == medActualizado.id);
    if (index != -1) {
      lista[index] = medActualizado;
      await _guardarLista(lista);
    }
  }

  // Eliminar un medicamento por ID
  static Future<void> eliminarPorId(String id) async {
    final lista = await obtenerMedicamentos();
    lista.removeWhere((m) => m.id == id);
    await _guardarLista(lista);
  }

  // Vaciar la lista de medicamentos
  static Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMedicamentos);
  }
}
