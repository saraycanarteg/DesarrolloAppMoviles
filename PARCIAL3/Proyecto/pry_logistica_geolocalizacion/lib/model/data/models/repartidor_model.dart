import '../../domain/entities/repartidor_entity.dart';

class RepartidorModel extends RepartidorEntity {
  const RepartidorModel({
    required super.uid,
    required super.nombre,
    required super.disponible,
    super.vehiculo,
    super.pedidoActualId,
  });

  factory RepartidorModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    return RepartidorModel(
      uid: uid,
      nombre: map['nombre'] ?? '',
      disponible: map['disponible'] ?? false,
      vehiculo: map['vehiculo'],
      pedidoActualId: map['pedidoActualId'],
    );
  }
}
