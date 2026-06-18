import '../model/cantidad_model.dart';

class CantidadController {
  Map<String, dynamic> calcularResultados(String preciosString) {
    if (preciosString.isEmpty) {
      return {"error": "Ingrese al menos un precio"};
    }

    // Dividir por comas y procesar
    final valores = preciosString.split(',').map((s) => s.trim()).toList();
    
    // Validar que no haya valores vacíos
    if (valores.any((v) => v.isEmpty)) {
      return {"error": "No ingrese valores vacíos entre comas"};
    }

    // Intentar convertir a double
    final precios = <double>[];
    for (String valor in valores) {
      final num = double.tryParse(valor);
      if (num == null) {
        return {"error": "El valor '$valor' no es un número válido"};
      }
      if (num < 0) {
        return {"error": "Los precios no pueden ser negativos"};
      }
      precios.add(num);
    }

    if (precios.isEmpty) {
      return {"error": "Ingrese al menos un precio"};
    }

    final modelo = CantidadModel(precios);
    final detalles = modelo.obtenerDetalleArticulos();

    return {
      "articulos": detalles,
      "costoTotal": modelo.costoTotal.toStringAsFixed(2),
      "descuentoTotal": modelo.descuentoTotal.toStringAsFixed(2),
      "totalAPagar": modelo.totalAPagar.toStringAsFixed(2),
    };
  }
}
