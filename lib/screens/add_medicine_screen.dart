import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medialert/screens/home_screen.dart';
import '../servicios/servicio_firestore.dart';
import '../helpers/notificacion_helper.dart'; // Para programar notificaciones de recordatorio

// Pantalla para agregar o editar un medicamento
class AddMedicineScreen extends StatefulWidget {
  final String userId; // ID del usuario
  final String? docId; // ID del documento si es edición
  final Map<String, dynamic>? medicamento; // Datos del medicamento (en caso de edición)

  const AddMedicineScreen({
    super.key,
    required this.userId,
    this.docId,
    this.medicamento,
  });

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>(); // Llave del formulario para validación
  final _nombreController = TextEditingController(); // Controlador del campo nombre
  final _dosisController = TextEditingController(); // Controlador del campo dosis
  TimeOfDay? _horaSeleccionada; // Hora seleccionada por el usuario
  List<bool> _diasSeleccionados = List.filled(7, false); // Lista para saber qué días están activos

  final FirestoreService _firestoreService = FirestoreService(); // Servicio para Firestore

  @override
  void initState() {
    super.initState();

    // Si estamos editando, cargamos los datos en los campos
    if (widget.medicamento != null) {
      _nombreController.text = widget.medicamento!['nombre'] ?? '';
      _dosisController.text = widget.medicamento!['dosis'] ?? '';
      final horaTexto = widget.medicamento!['hora'];
      if (horaTexto != null && horaTexto is String && horaTexto.contains(':')) {
        final partes = horaTexto.split(":");
        final hora = int.tryParse(partes[0]);
        final minuto = int.tryParse(partes[1].split(' ')[0]);
        if (hora != null && minuto != null) {
          _horaSeleccionada = TimeOfDay(hour: hora, minute: minuto);
        }
      }
      final dias = List<int>.from(widget.medicamento!['diasSemana'] ?? []);
      for (var dia in dias) {
        if (dia >= 1 && dia <= 7) _diasSeleccionados[dia - 1] = true;
      }
    }
  }

  // Método para guardar o actualizar el medicamento
  Future<void> _guardar() async {
    if (_formKey.currentState!.validate() && _horaSeleccionada != null) {
      final horaTexto = _horaSeleccionada!.format(context);
      final diasSeleccionados = <int>[];

      for (int i = 0; i < 7; i++) {
        if (_diasSeleccionados[i]) diasSeleccionados.add(i + 1);
      }

      final datos = {
        'nombre': _nombreController.text,
        'dosis': _dosisController.text,
        'hora': horaTexto,
        'diasSemana': diasSeleccionados,
        'fechaCreacion': DateTime.now(),
      };

      if (widget.docId != null) {
        // Actualizar si hay docId
        await _firestoreService.actualizarMedicamento(
          widget.userId,
          widget.docId!,
          datos,
        );
      } else {
        // Agregar nuevo medicamento
        await _firestoreService.agregarMedicamento(widget.userId, datos);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.docId != null
                ? 'Medicamento actualizado correctamente'
                : 'Medicamento guardado correctamente'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userId: widget.userId),
          ),
        );
      }
    }
  }

  // Método para eliminar medicamento (si es edición)
  Future<void> _eliminar() async {
    if (widget.docId != null) {
      await _firestoreService.eliminarMedicamento(widget.userId, widget.docId!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento eliminado correctamente')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userId: widget.userId),
          ),
        );
      }
    }
  }

  // Selector de hora
  void _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _horaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.montserrat(
      fontSize: 20,
      color: Colors.black87, // Texto oscuro y legible
    );

    // Color principal suave azul 
    const Color azulSalud = Color(0xFF4A90E2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.docId != null ? 'Editar Medicamento' : 'Agregar Medicamento',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: azulSalud,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo nombre del medicamento
              TextFormField(
                controller: _nombreController,
                style: textStyle,
                decoration: const InputDecoration(
                  labelText: 'Nombre del medicamento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 20),

              // Campo dosis
              TextFormField(
                controller: _dosisController,
                style: textStyle,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese la dosis' : null,
              ),
              const SizedBox(height: 20),

              // Días de la semana
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Días de la semana:', style: textStyle),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children: List.generate(7, (index) {
                  const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                  return FilterChip(
                    label: Text(
                      dias[index],
                      style: TextStyle(
                        color: _diasSeleccionados[index] ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: _diasSeleccionados[index],
                    selectedColor: azulSalud,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey[200],
                    onSelected: (bool selected) {
                      setState(() {
                        _diasSeleccionados[index] = selected;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Selector de hora
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _seleccionarHora,
                    icon: const Icon(Icons.access_time),
                    label: const Text('Seleccionar Hora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azulSalud,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _horaSeleccionada == null
                          ? 'Hora no seleccionada'
                          : _horaSeleccionada!.format(context),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Botón Guardar / Actualizar
              ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 22),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(widget.docId != null ? 'Actualizar' : 'Guardar'),
              ),

              // Botón Eliminar si estamos editando
              if (widget.docId != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _eliminar,
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Libera recursos cuando se destruye la pantalla
  @override
  void dispose() {
    _nombreController.dispose();
    _dosisController.dispose();
    super.dispose();
  }
}
