import '../../domain/entities/ubicacion_entity.dart';

class UbicacionModel extends UbicacionEntity {
  const UbicacionModel({
    required super.repartidorId,
    required super.lat,
    required super.lng,
    super.heading,
    super.speed,
    super.accuracy,
    required super.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'repartidorId': repartidorId,
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'speed': speed,
      'accuracy': accuracy,
      'timestamp': timestamp,
    };
  }

  factory UbicacionModel.fromMap(Map<dynamic, dynamic> map) {
    return UbicacionModel(
      repartidorId: map['repartidorId'] ?? '',
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      heading: map['heading'] != null ? (map['heading']).toDouble() : null,
      speed: map['speed'] != null ? (map['speed']).toDouble() : null,
      accuracy: map['accuracy'] != null ? (map['accuracy']).toDouble() : null,
      timestamp: map['timestamp'] ?? 0,
    );
  }
}
