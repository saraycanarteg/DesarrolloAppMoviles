import 'package:deber_p1/model/peso_model.dart';

class PesoController {
  String procesar(String pesajes1Str, String pesajes2Str) {
    try {
      // Validar campos vacíos
      if (pesajes1Str.isEmpty || pesajes2Str.isEmpty) {
        return 'Todos los campos son obligatorios';
      }

      // Parsear pesajes de la primera balanza
      final pesajes1 = pesajes1Str.split(',').map((e) => double.parse(e.trim())).toList();

      // Parsear pesajes de la segunda balanza
      final pesajes2 = pesajes2Str.split(',').map((e) => double.parse(e.trim())).toList();

      // Validar que haya exactamente 10 pesajes en cada balanza
      if (pesajes1.length != 10) {
        return 'Ingrese exactamente 10 pesajes en la primera balanza';
      }

      if (pesajes2.length != 10) {
        return 'Ingrese exactamente 10 pesajes en la segunda balanza';
      }

      // Validar valores positivos
      if (pesajes1.any((p) => p <= 0) || pesajes2.any((p) => p <= 0)) {
        return 'Los pesos deben ser valores positivos';
      }

      // Calcular
      final resultado = PesoModel.calcularPeso(pesajes1, pesajes2);

      return '''
${resultado.estado} ${resultado.diferencia.toStringAsFixed(2)} kg

Promedio Pesaje 1: ${resultado.promedioPeso1.toStringAsFixed(2)} kg
Promedio Pesaje 2: ${resultado.promedioPeso2.toStringAsFixed(2)} kg
      ''';
    } catch (e) {
      return 'Ingrese valores válidos. Formato: 10 pesos separados por coma en cada campo';
    }
  }
}

