import 'mascota.dart';

class Solicitud {
  final int?     id;
  final String   nombreSolicitante;
  final String   telefono;
  final String   motivo;
  final int      mascotaId;
  final bool     aprobada;
  final DateTime? fechaSolicitud;
  final Mascota?  mascota;

  Solicitud({
    this.id,
    required this.nombreSolicitante,
    required this.telefono,
    required this.motivo,
    required this.mascotaId,
    this.aprobada = false,
    this.fechaSolicitud,
    this.mascota,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) => Solicitud(
    id:                json['id'],
    nombreSolicitante: json['nombre_solicitante'],
    telefono:          json['telefono'],
    motivo:            json['motivo'],
    mascotaId:         json['mascota_id'],
    aprobada:          json['aprobada'] ?? false,
    fechaSolicitud:    json['fecha_solicitud'] != null
        ? DateTime.parse(json['fecha_solicitud'])
        : null,
    mascota: json['mascota'] != null
        ? Mascota.fromJson(json['mascota'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'nombre_solicitante': nombreSolicitante,
    'telefono':           telefono,
    'motivo':             motivo,
    'mascota_id':         mascotaId,
  };
}