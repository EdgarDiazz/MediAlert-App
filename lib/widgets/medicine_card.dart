import 'package:flutter/material.dart';
import '../models/medicamento.dart';

class MedicineCard extends StatelessWidget {
  final Medicamento medicamento;
  final VoidCallback onDelete;

  const MedicineCard({
    super.key,
    required this.medicamento,
    required this.onDelete,
  });

  String _formatearDias(List<dynamic>? dias) {
    if (dias == null || dias.isEmpty) return 'No especificado';
    const nombresDias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias.map((d) => nombresDias[(d - 1) % 7]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.teal),
        title: Text(
          medicamento.nombre ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '💊 Dosis: ${medicamento.dosis ?? 'No especificada'}\n'
          '🕒 Hora: ${medicamento.hora ?? 'No asignada'}\n'
          '📅 Días: ${_formatearDias(medicamento.diasSemana)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
