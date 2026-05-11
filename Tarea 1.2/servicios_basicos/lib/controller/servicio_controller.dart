import '../model/servicio_model.dart';

class ServicioController {
  // Tarifas base por servicio
  final Map<String, double> tarifas = {
    'Agua Potable': 0.50, // por m³
    'Energía Eléctrica': 0.15, // por kWh
    'Internet y Telefonía': 25.0, // fijo
    'TV por Cable': 20.0, // fijo
    'Otros Pagos': 0.0, // variable
  };

  String procesarPago({
    required String nombreCliente,
    required String cedulaCliente,
    required String direccionCliente,
    required String tipoServicio,
    required String consumoStr,
    required bool tieneDescuento,
    required double porcentajeDescuento,
    required bool tieneRecargo,
    required double porcentajeRecargo,
  }) {
    // Validar datos del cliente
    if (nombreCliente.isEmpty) {
      return 'Debe ingresar el nombre del cliente';
    }
    if (cedulaCliente.isEmpty) {
      return 'Debe ingresar la cédula del cliente';
    }
    if (direccionCliente.isEmpty) {
      return 'Debe ingresar la dirección del cliente';
    }

    // Validar servicio
    if (tipoServicio.isEmpty) {
      return 'Debe seleccionar un tipo de servicio';
    }

    // Validar consumo
    if (consumoStr.isEmpty) {
      return 'Debe ingresar el consumo o valor del servicio';
    }

    try {
      final consumo = double.parse(consumoStr);

      if (consumo < 0) {
        return 'El consumo debe ser un valor positivo';
      }

      // Obtener tarifa
      final tarifa = tarifas[tipoServicio] ?? 0.0;

      // Crear cliente
      final cliente = ClienteModel(
        nombre: nombreCliente,
        cedula: cedulaCliente,
        direccion: direccionCliente,
      );

      // Calcular pago
      final subtotal = consumo * tarifa;

      // Aplicar descuento
      double montoDescuento = 0.0;
      if (tieneDescuento && porcentajeDescuento > 0) {
        montoDescuento = subtotal * (porcentajeDescuento / 100);
      }

      // Aplicar recargo
      double montoRecargo = 0.0;
      if (tieneRecargo && porcentajeRecargo > 0) {
        montoRecargo = subtotal * (porcentajeRecargo / 100);
      }

      // Calcular total
      final total = subtotal - montoDescuento + montoRecargo;

      // Crear modelo de pago
      final pago = PagoServicioModel(
        cliente: cliente,
        tipoServicio: tipoServicio,
        consumoValor: consumo,
        tarifa: tarifa,
        subtotal: subtotal,
        tieneDescuento: tieneDescuento,
        porcentajeDescuento: porcentajeDescuento,
        tieneRecargo: tieneRecargo,
        porcentajeRecargo: porcentajeRecargo,
        montoDescuento: montoDescuento,
        montoRecargo: montoRecargo,
        total: total,
      );

      return _formatearResultado(pago);
    } catch (e) {
      return 'El consumo debe ser un número válido';
    }
  }

  String _formatearResultado(PagoServicioModel pago) {
    final detalles = pago.obtenerDetalles();
    final cliente = detalles['cliente'] as ClienteModel;
    final tipoServicio = detalles['tipoServicio'] as String;
    final consumoValor = detalles['consumoValor'] as double;
    final tarifa = detalles['tarifa'] as double;
    final subtotal = detalles['subtotal'] as double;
    final tieneDescuento = detalles['tieneDescuento'] as bool;
    final porcentajeDescuento = detalles['porcentajeDescuento'] as double;
    final tieneRecargo = detalles['tieneRecargo'] as bool;
    final porcentajeRecargo = detalles['porcentajeRecargo'] as double;
    final montoDescuento = detalles['montoDescuento'] as double;
    final montoRecargo = detalles['montoRecargo'] as double;
    final total = detalles['total'] as double;

    String resultado = '''
====================================
     COMPROBANTE DE PAGO
     SERVICIOS BÁSICOS
====================================

DATOS DEL CLIENTE:
====================================
Nombre: ${cliente.nombre}
Cédula: ${cliente.cedula}
Dirección: ${cliente.direccion}

====================================
DETALLE DEL SERVICIO:
====================================
Tipo: $tipoServicio
Consumo/Valor: ${consumoValor.toStringAsFixed(2)}
Tarifa: \$${tarifa.toStringAsFixed(2)}
Subtotal: \$${subtotal.toStringAsFixed(2)}
''';

    if (tieneDescuento && montoDescuento > 0) {
      resultado += 'Descuento ($porcentajeDescuento%): -\$${montoDescuento.toStringAsFixed(2)}\n';
    }

    if (tieneRecargo && montoRecargo > 0) {
      resultado += 'Recargo ($porcentajeRecargo%): +\$${montoRecargo.toStringAsFixed(2)}\n';
    }

    resultado += '''
====================================
TOTAL A PAGAR: \$${total.toStringAsFixed(2)}
====================================
Fecha: ${DateTime.now().toString().split('.')[0]}
''';

    return resultado;
  }
}
