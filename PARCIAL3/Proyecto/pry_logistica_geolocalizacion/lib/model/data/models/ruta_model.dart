import '../../domain/entities/ruta_entity.dart';

class RutaModel extends RutaEntity {
  const RutaModel({
    required super.id,
    required super.pedidoId,
    required super.repartidorId,
    required super.polylineCodificado,
    required super.distanciaKm,
    required super.duracionMin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedidoId': pedidoId,
      'repartidorId': repartidorId,
      'polylineCodificado': polylineCodificado,
      'distanciaKm': distanciaKm,
      'duracionMin': duracionMin,
    };
  }
}
