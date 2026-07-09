import '../../domain/entities/repartidor_entity.dart';

class RepartidorModel extends RepartidorEntity {
  const RepartidorModel({
    required super.uid,
    required super.nombre,
    required super.disponible,
    super.vehiculo,
    super.pedidoActualId,
    super.cedula,
    super.telefono,
    super.email,
    super.vehiculoTipo,
    super.vehiculoMarca,
    super.vehiculoPlaca,
  });

  factory RepartidorModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    return RepartidorModel(
      uid: uid,
      nombre: map['nombre'] ?? '',
      disponible: map['disponible'] ?? false,
      vehiculo: map['vehiculo'],
      pedidoActualId: map['pedidoActualId'],
      cedula: map['cedula'],
      telefono: map['telefono'],
      email: map['email'],
      vehiculoTipo: map['vehiculoTipo'],
      vehiculoMarca: map['vehiculoMarca'],
      vehiculoPlaca: map['vehiculoPlaca'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'disponible': disponible,
      'vehiculo': vehiculo,
      'pedidoActualId': pedidoActualId,
      'cedula': cedula,
      'telefono': telefono,
      'email': email,
      'vehiculoTipo': vehiculoTipo,
      'vehiculoMarca': vehiculoMarca,
      'vehiculoPlaca': vehiculoPlaca,
    };
  }
}
