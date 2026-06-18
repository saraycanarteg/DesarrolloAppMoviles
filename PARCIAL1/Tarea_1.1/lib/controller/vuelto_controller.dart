import 'package:deber_p1/model/vuelto_model.dart';
class VueltoController {

  String procesar(String precio, String vaentregado) {

    final precioin = double.tryParse(precio);
    final vaentregadoin = double.tryParse(vaentregado);

    // validar null
    if (precioin == null || vaentregadoin == null) {
      return 'Ingrese valores válidos';
    }

    // validar lógica
    if (precioin < 0 || vaentregadoin < 0) {
      return 'No se permiten valores negativos';
    }

    if (vaentregadoin < precioin) {
      return 'El valor entregado no puede ser menor al precio';
    }

    // calcular
    final cambio = VueltoModel.calcularvuelto(vaentregadoin, precioin);
    final monedasStr = cambio.monedasCambio
        .map((m) => m.toStringAsFixed(2))
        .join(', ');

    return '''
    Precio Producto: ${precioin.toStringAsFixed(2)}
    Valor Entregado: ${vaentregadoin.toStringAsFixed(2)}
    Vuelto: ${cambio.vuelto.toStringAsFixed(2)}
    Monedas: $monedasStr
    ''';
  }
}