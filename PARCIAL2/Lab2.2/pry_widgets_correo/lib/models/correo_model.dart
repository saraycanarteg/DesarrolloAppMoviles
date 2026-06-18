class Correo {
  final String id;
  final String remitente;
  final String asunto;
  final String cuerpo;
  final DateTime fecha;
  bool leido;

  Correo({
    required this.id,
    required this.remitente,
    required this.asunto,
    required this.cuerpo,
    required this.fecha,
    this.leido = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remitente': remitente,
      'asunto': asunto,
      'cuerpo': cuerpo,
      'fecha': fecha.toIso8601String(),
      'leido': leido,
    };
  }

  factory Correo.fromJson(Map<String, dynamic> json) {
    return Correo(
      id: json['id'] as String,
      remitente: json['remitente'] as String,
      asunto: json['asunto'] as String,
      cuerpo: json['cuerpo'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      leido: json['leido'] as bool,
    );
  }
}