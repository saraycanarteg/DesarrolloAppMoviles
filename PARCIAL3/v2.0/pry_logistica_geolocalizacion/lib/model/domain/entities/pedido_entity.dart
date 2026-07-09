enum EstadoPedido {
  pendiente,
  esperandoConfirmacion,
  asignado,
  enRutaATienda,
  recogido,
  enRutaACliente,
  entregado,
}

class PedidoEntity {
  final String id;
  final String clienteNombre;

  // Origen
  final String direccionOrigen;
  final double latOrigen;
  final double lngOrigen;

  // Destino
  final String direccionDestino;
  final double latDestino;
  final double lngDestino;

  final EstadoPedido estado;
  final String? repartidorId;
  final String? repartidorNombre;
  final String? repartidorVehiculo;
  final String creadoPor;
  final int creadoEn;

  // Timestamps de trazabilidad
  final int? asignadoEn;
  final int? enRutaEn; // inicio del viaje hacia la tienda
  final int? recogidoEn;
  final int? enRutaClienteEn;
  final int? entregadoEn;

  const PedidoEntity({
    required this.id,
    required this.clienteNombre,
    required this.direccionOrigen,
    required this.latOrigen,
    required this.lngOrigen,
    required this.direccionDestino,
    required this.latDestino,
    required this.lngDestino,
    required this.estado,
    this.repartidorId,
    this.repartidorNombre,
    this.repartidorVehiculo,
    required this.creadoPor,
    required this.creadoEn,
    this.asignadoEn,
    this.enRutaEn,
    this.recogidoEn,
    this.enRutaClienteEn,
    this.entregadoEn,
  });

  /// Estados en los que el pedido ya fue aceptado y sigue activo
  /// (el repartidor tiene una entrega en curso).
  bool get enCurso =>
      estado == EstadoPedido.asignado ||
      estado == EstadoPedido.enRutaATienda ||
      estado == EstadoPedido.recogido ||
      estado == EstadoPedido.enRutaACliente;

  static EstadoPedido stringToEstado(String estadoStr) {
    switch (estadoStr) {
      case 'pendiente':
        return EstadoPedido.pendiente;
      case 'esperando_confirmacion':
        return EstadoPedido.esperandoConfirmacion;
      case 'asignado':
        return EstadoPedido.asignado;
      case 'en_ruta_a_tienda':
        return EstadoPedido.enRutaATienda;
      case 'recogido':
        return EstadoPedido.recogido;
      case 'en_ruta_a_cliente':
        return EstadoPedido.enRutaACliente;
      case 'en_ruta': // alias legado (datos previos a los estados intermedios)
        return EstadoPedido.enRutaACliente;
      case 'entregado':
        return EstadoPedido.entregado;
      default:
        throw ArgumentError('EstadoPedido no válido: $estadoStr');
    }
  }

  static String estadoToString(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return 'pendiente';
      case EstadoPedido.esperandoConfirmacion:
        return 'esperando_confirmacion';
      case EstadoPedido.asignado:
        return 'asignado';
      case EstadoPedido.enRutaATienda:
        return 'en_ruta_a_tienda';
      case EstadoPedido.recogido:
        return 'recogido';
      case EstadoPedido.enRutaACliente:
        return 'en_ruta_a_cliente';
      case EstadoPedido.entregado:
        return 'entregado';
    }
  }

  PedidoEntity copyWith({
    EstadoPedido? estado,
    String? repartidorId,
    int? asignadoEn,
    int? enRutaEn,
    int? recogidoEn,
    int? enRutaClienteEn,
    int? entregadoEn,
  }) {
    return PedidoEntity(
      id: this.id,
      clienteNombre: this.clienteNombre,
      direccionOrigen: this.direccionOrigen,
      latOrigen: this.latOrigen,
      lngOrigen: this.lngOrigen,
      direccionDestino: this.direccionDestino,
      latDestino: this.latDestino,
      lngDestino: this.lngDestino,
      estado: estado ?? this.estado,
      repartidorId: repartidorId ?? this.repartidorId,
      repartidorNombre: this.repartidorNombre,
      repartidorVehiculo: this.repartidorVehiculo,
      creadoPor: this.creadoPor,
      creadoEn: this.creadoEn,
      asignadoEn: asignadoEn ?? this.asignadoEn,
      enRutaEn: enRutaEn ?? this.enRutaEn,
      recogidoEn: recogidoEn ?? this.recogidoEn,
      enRutaClienteEn: enRutaClienteEn ?? this.enRutaClienteEn,
      entregadoEn: entregadoEn ?? this.entregadoEn,
    );
  }
}
