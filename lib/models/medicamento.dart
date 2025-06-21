class Medicamento {
  final String? nombre;
  final String? dosis;
  final String? hora;
  final List<dynamic>? diasSemana;
  bool eliminado;
  String estado;

  Medicamento({
    this.nombre,
    this.dosis,
    this.hora,
    this.diasSemana,
    this.eliminado = false,
    this.estado = 'Activo',
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      nombre: json['nombre'],
      dosis: json['dosis'],
      hora: json['hora'],
      diasSemana: List<dynamic>.from(json['diasSemana'] ?? []),
      eliminado: json['eliminado'] ?? false,
      estado: json['estado'] ?? 'Activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dosis': dosis,
      'hora': hora,
      'diasSemana': diasSemana,
      'eliminado': eliminado,
      'estado': estado,
    };
  }
}
