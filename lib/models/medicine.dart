import 'package:flutter/material.dart';

class Medicine {
  final String id;
  final String nombre;
  final String dosis;
  final TimeOfDay hora;
  final List<bool> dias;
  final bool tomado;

  Medicine({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.hora,
    required this.dias,
    required this.tomado,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'hora': '${hora.hour}:${hora.minute}',
        'dias': dias,
        'tomado': tomado,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final horaParts = (json['hora'] as String).split(':');
    final hour = int.parse(horaParts[0]);
    final minute = int.parse(horaParts[1]);

    return Medicine(
      id: json['id'],
      nombre: json['nombre'],
      dosis: json['dosis'],
      hora: TimeOfDay(hour: hour, minute: minute),
      dias: List<bool>.from(json['dias']),
      tomado: json['tomado'],
    );
  }
}
  