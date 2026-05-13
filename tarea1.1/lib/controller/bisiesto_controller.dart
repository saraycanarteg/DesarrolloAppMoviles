import 'package:deber_p1/model/bisiesto_model.dart';

class BisiestoController {
  String procesar(String yearIngresado) {
    try {
      final year = int.parse(yearIngresado.trim());

      if (year < 0) {
        return 'Ingrese un año válido (número positivo)';
      }

      final resultado = BisiestoModel.calcular(year);

      final estado = resultado.esBisiesto ? 'SÍ es bisiesto' : 'NO es bisiesto';

      return '''
      Año: ${resultado.year}
      $estado
      ''';
    } catch (e) {
      return 'Ingrese un año válido (número entero)';
    }
  }
}
