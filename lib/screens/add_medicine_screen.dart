import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medialert/screens/main_screen.dart';
import '../servicios/servicio_firestore.dart';
import '../helpers/notificacion_helper.dart';

class AddMedicineScreen extends StatefulWidget {
  final String userId;
  final String? docId;
  final Map<String, dynamic>? medicamento;

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
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _dosisController = TextEditingController();
  TimeOfDay? _horaSeleccionada;
  final List<bool> _diasSeleccionados = List.filled(7, false);

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
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

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      if (_horaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Por favor selecciona una hora para el medicamento'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
        return;
      }

      final diasSeleccionados = <int>[];
      for (int i = 0; i < 7; i++) {
        if (_diasSeleccionados[i]) diasSeleccionados.add(i + 1);
      }

      if (diasSeleccionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Por favor selecciona al menos un día de la semana'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
        return;
      }

      final nombre = _nombreController.text;
      final horaTexto = _horaSeleccionada!.format(context);

      debugPrint('📆 Programando $nombre a las $horaTexto en días: $diasSeleccionados');

      final datos = {
        'nombre': nombre,
        'dosis': _dosisController.text,
        'hora': horaTexto,
        'diasSemana': diasSeleccionados,
        'fechaCreacion': DateTime.now(),
      };

      try {
        if (widget.docId != null && widget.medicamento != null) {
          final nombreAntiguo = widget.medicamento!['nombre'] ?? '';
          final diasAntiguos = List<int>.from(widget.medicamento!['diasSemana'] ?? []);

          await NotificacionHelper.cancelarNotificaciones(
            nombreMedicamento: nombreAntiguo,
            diasSemana: diasAntiguos,
          );

          await _firestoreService.actualizarMedicamento(
            widget.userId,
            widget.docId!,
            datos,
          );
        } else {
          await _firestoreService.agregarMedicamento(widget.userId, datos);
        }

        await NotificacionHelper.programarNotificaciones(
          nombreMedicamento: nombre,
          hora: _horaSeleccionada!,
          diasSemana: diasSeleccionados,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.docId != null
                ? '✅ Medicamento actualizado correctamente. Las notificaciones han sido reprogramadas.'
                : '✅ Medicamento guardado correctamente. Recibirás notificaciones en los días y hora seleccionados.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainScreen(userId: widget.userId),
            ),
          );
        }
      } catch (e) {
        print('❌ Error al guardar: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar el medicamento. Por favor intenta nuevamente.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      }
    }
  }

  Future<void> _eliminar() async {
    if (widget.docId != null && widget.medicamento != null) {
      final nombre = widget.medicamento!['nombre'] ?? '';
      final dias = List<int>.from(widget.medicamento!['diasSemana'] ?? []);

      try {
        await NotificacionHelper.cancelarNotificaciones(
          nombreMedicamento: nombre,
          diasSemana: dias,
        );

        await _firestoreService.eliminarMedicamento(widget.userId, widget.docId!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Medicamento eliminado correctamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainScreen(userId: widget.userId),
            ),
          );
        }
      } catch (e) {
        print('❌ Error al eliminar: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar el medicamento. Por favor intenta nuevamente.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      }
    }
  }

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
    final textStyle = GoogleFonts.montserrat(fontSize: 18, color: Colors.black87);
    final titleStyle = GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87);
    const Color azulSalud = Color(0xFF4A90E2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.docId != null ? 'Editar Medicamento' : 'Agregar Medicamento',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: azulSalud,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del medicamento
              Text('Nombre del medicamento:', style: titleStyle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreController,
                style: textStyle.copyWith(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Ejemplo: Aspirina, Paracetamol',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) => value!.isEmpty ? 'Por favor ingrese el nombre del medicamento' : null,
              ),
              const SizedBox(height: 24),
              
              // Dosis
              Text('Dosis:', style: titleStyle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dosisController,
                style: textStyle.copyWith(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Ejemplo: 1 tableta, 2 cápsulas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) => value!.isEmpty ? 'Por favor ingrese la dosis' : null,
              ),
              const SizedBox(height: 24),
              
              // Días de la semana
              Text('Días de la semana:', style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'Selecciona los días en que debes tomar este medicamento:',
                style: textStyle.copyWith(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(7, (index) {
                  const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
                  return FilterChip(
                    label: Text(
                      dias[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _diasSeleccionados[index] ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: _diasSeleccionados[index],
                    selectedColor: azulSalud,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onSelected: (bool selected) {
                      setState(() {
                        _diasSeleccionados[index] = selected;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              
              // Hora
              Text('Hora de toma:', style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'Selecciona la hora en que debes tomar este medicamento:',
                style: textStyle.copyWith(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: _horaSeleccionada != null ? azulSalud : Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: _horaSeleccionada != null ? azulSalud.withOpacity(0.1) : Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _horaSeleccionada != null ? azulSalud : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _horaSeleccionada == null
                            ? 'Toca para seleccionar la hora'
                            : _horaSeleccionada!.format(context),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _horaSeleccionada != null ? azulSalud : Colors.grey[600],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _seleccionarHora,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulSalud,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      child: const Text('Seleccionar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    elevation: 3,
                  ),
                  child: Text(widget.docId != null ? 'Actualizar Medicamento' : 'Guardar Medicamento'),
                ),
              ),
              
              // Botón eliminar (solo si es edición)
              if (widget.docId != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _eliminar,
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text('Eliminar Medicamento', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dosisController.dispose();
    super.dispose();
  }
}
