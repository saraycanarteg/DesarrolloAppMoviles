import '../model/hamburguesa_model.dart';

class HamburguesaController {
  Map<String, dynamic> calcularResultados(
    String sencillasStr,
    String doblesStr,
    String triplesStr,
    bool usaTarjeta,
  ) {
    if (sencillasStr.isEmpty || doblesStr.isEmpty || triplesStr.isEmpty) {
      return {"error": "Ingrese todas las cantidades"};
    }

    final sencillas = int.tryParse(sencillasStr);
    final dobles = int.tryParse(doblesStr);
    final triples = int.tryParse(triplesStr);

    if (sencillas == null || dobles == null || triples == null) {
      return {"error": "Ingrese números enteros válidos"};
    }

    if (sencillas < 0 || dobles < 0 || triples < 0) {
      return {"error": "Las cantidades no pueden ser negativas"};
    }

    if (sencillas == 0 && dobles == 0 && triples == 0) {
      return {"error": "Debe pedir al menos una hamburguesa"};
    }

    final hamburguesas = {
      'S': sencillas,
      'D': dobles,
      'T': triples,
    };

    final modelo = HamburguesaModel(
      hamburguesas: hamburguesas,
      usaTarjeta: usaTarjeta,
    );

    final resultados = modelo.obtenerResultados();

    return {
      "sencillas": resultados['sencillas'].toString(),
      "dobles": resultados['dobles'].toString(),
      "triples": resultados['triples'].toString(),
      "subtotal": (resultados['subtotal'] as double).toStringAsFixed(2),
      "cargo": (resultados['cargo'] as double).toStringAsFixed(2),
      "total": (resultados['total'] as double).toStringAsFixed(2),
      "usaTarjeta": resultados['usaTarjeta'],
    };
  }
}
