import '../../domain/entities/pedido_entity.dart';

class PedidoModel extends PedidoEntity {
  const PedidoModel({
    required super.id,
    required super.clienteNombre,
    required super.direccionOrigen,
    required super.latOrigen,
    required super.lngOrigen,
    required super.direccionDestino,
    required super.latDestino,
    required super.lngDestino,
    required super.estado,
    super.repartidorId,
    super.repartidorNombre,
    super.repartidorVehiculo,
    required super.creadoPor,
    required super.creadoEn,
    super.asignadoEn,
    super.enRutaEn,
    super.recogidoEn,
    super.enRutaClienteEn,
    super.entregadoEn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteNombre': clienteNombre,
      'direccionOrigen': direccionOrigen,
      'latOrigen': latOrigen,
      'lngOrigen': lngOrigen,
      'direccionDestino': direccionDestino,
      'latDestino': latDestino,
      'lngDestino': lngDestino,
      'estado': PedidoEntity.estadoToString(estado),
      'repartidorId': repartidorId,
      'creadoPor': creadoPor,
      'creadoEn': creadoEn,
      'asignadoEn': asignadoEn,
      'enRutaEn': enRutaEn,
      'recogidoEn': recogidoEn,
      'enRutaClienteEn': enRutaClienteEn,
      'entregadoEn': entregadoEn,
    };
  }

  factory PedidoModel.fromMap(Map<dynamic, dynamic> map) {
    return PedidoModel(
      id: map['id'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      direccionOrigen: map['direccionOrigen'] ?? '',
      latOrigen: (map['latOrigen'] ?? 0.0).toDouble(),
      lngOrigen: (map['lngOrigen'] ?? 0.0).toDouble(),
      direccionDestino: map['direccionDestino'] ?? '',
      latDestino: (map['latDestino'] ?? 0.0).toDouble(),
      lngDestino: (map['lngDestino'] ?? 0.0).toDouble(),
      estado: PedidoEntity.stringToEstado(map['estado'] ?? 'pendiente'),
      repartidorId: map['repartidorId'],
      repartidorNombre: map['repartidorNombre'],
      repartidorVehiculo: map['repartidorVehiculo'],
      creadoPor: map['creadoPor'] ?? '',
      creadoEn: map['creadoEn'] ?? 0,
      asignadoEn: map['asignadoEn'],
      enRutaEn: map['enRutaEn'],
      recogidoEn: map['recogidoEn'],
      enRutaClienteEn: map['enRutaClienteEn'],
      entregadoEn: map['entregadoEn'],
    );
  }
}
