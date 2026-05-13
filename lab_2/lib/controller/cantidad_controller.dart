import '../model/cantidad_model.dart';

class CantidadController {
  Map<String, dynamic> calcularResultados(String cantidadesString) {
    if (cantidadesString.isEmpty) {
      return {"error": "Ingrese al menos una cantidad"};
    }

    // Dividir por comas y procesar
    final valores = cantidadesString.split(',').map((s) => s.trim()).toList();
    
    // Validar que no haya valores vacíos
    if (valores.any((v) => v.isEmpty)) {
      return {"error": "No ingrese valores vacíos entre comas"};
    }

    // Intentar convertir a double
    final cantidades = <double>[];
    for (String valor in valores) {
      final num = double.tryParse(valor);
      if (num == null) {
        return {"error": "El valor '$valor' no es un número válido"};
      }
      cantidades.add(num);
    }

    if (cantidades.isEmpty) {
      return {"error": "Ingrese al menos una cantidad"};
    }

    final modelo = CantidadModel(cantidades);
    final resultados = modelo.obtenerResultados();

    return {
      "ceros": resultados['ceros'].toString(),
      "negativos": resultados['negativos'].toString(),
      "positivos": resultados['positivos'].toString(),
      "total": resultados['total'].toString(),
    };
  }
}
