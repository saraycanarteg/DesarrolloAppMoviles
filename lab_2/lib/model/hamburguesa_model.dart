class HamburguesaModel {
  static const double precioSencilla = 20.0;
  static const double precioDoble = 25.0;
  static const double precioTriple = 28.0;
  static const double porcentajeTarjeta = 0.05;

  final Map<String, int> hamburguesas;
  final bool usaTarjeta;

  HamburguesaModel({
    required this.hamburguesas,
    required this.usaTarjeta,
  });

  double get subtotal {
    double total = 0.0;
    hamburguesas.forEach((tipo, cantidad) {
      switch (tipo.toUpperCase()) {
        case 'S':
          total += precioSencilla * cantidad;
          break;
        case 'D':
          total += precioDoble * cantidad;
          break;
        case 'T':
          total += precioTriple * cantidad;
          break;
      }
    });
    return total;
  }

  double get cargoPorTarjeta {
    return usaTarjeta ? subtotal * porcentajeTarjeta : 0.0;
  }

  double get totalAPagar {
    return subtotal + cargoPorTarjeta;
  }

  Map<String, dynamic> obtenerResultados() {
    return {
      'sencillas': hamburguesas['S'] ?? 0,
      'dobles': hamburguesas['D'] ?? 0,
      'triples': hamburguesas['T'] ?? 0,
      'subtotal': subtotal,
      'cargo': cargoPorTarjeta,
      'total': totalAPagar,
      'usaTarjeta': usaTarjeta,
    };
  }
}
