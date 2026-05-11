class ServicioModel {
  final String nombre;
  final double tarifaBase;
  final double unidad; // Consumo o valor base

  ServicioModel({
    required this.nombre,
    required this.tarifaBase,
    required this.unidad,
  });
}

class ClienteModel {
  final String nombre;
  final String cedula;
  final String direccion;

  ClienteModel({
    required this.nombre,
    required this.cedula,
    required this.direccion,
  });
}

class PagoServicioModel {
  final ClienteModel cliente;
  final String tipoServicio;
  final double consumoValor;
  final double tarifa;
  final double subtotal;
  final bool tieneDescuento;
  final double porcentajeDescuento;
  final bool tieneRecargo;
  final double porcentajeRecargo;
  final double montoDescuento;
  final double montoRecargo;
  final double total;

  PagoServicioModel({
    required this.cliente,
    required this.tipoServicio,
    required this.consumoValor,
    required this.tarifa,
    required this.subtotal,
    required this.tieneDescuento,
    required this.porcentajeDescuento,
    required this.tieneRecargo,
    required this.porcentajeRecargo,
    required this.montoDescuento,
    required this.montoRecargo,
    required this.total,
  });

  Map<String, dynamic> obtenerDetalles() {
    return {
      'cliente': cliente,
      'tipoServicio': tipoServicio,
      'consumoValor': consumoValor,
      'tarifa': tarifa,
      'subtotal': subtotal,
      'tieneDescuento': tieneDescuento,
      'porcentajeDescuento': porcentajeDescuento,
      'tieneRecargo': tieneRecargo,
      'porcentajeRecargo': porcentajeRecargo,
      'montoDescuento': montoDescuento,
      'montoRecargo': montoRecargo,
      'total': total,
    };
  }
}
