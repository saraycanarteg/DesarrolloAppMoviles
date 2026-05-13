import 'package:deber_p1/model/perfecto_model.dart';

class PerfectoController {
  String procesar(String numeroIngresado) {
    try {
      final numero = int.parse(numeroIngresado.trim());

      if (numero < 1) {
        return 'Ingrese un número positivo mayor a 0';
      }

      final resultado = PerfectoModel.calcular(numero);

      final divisoresStr = resultado.divisores.join(', ');
      final estado = resultado.esPerfecto ? 'SÍ es perfecto' : 'NO es perfecto';

      return '''
      Número: ${resultado.numero}
      Divisores (sin incluir el número): $divisoresStr
      Suma de divisores: ${resultado.sumaDivisores}
      $estado
      ''';
    } catch (e) {
      return 'Ingrese un número válido (número entero positivo)';
    }
  }
}
