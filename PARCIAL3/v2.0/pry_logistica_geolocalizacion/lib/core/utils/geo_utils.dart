import 'dart:math' as math;

class GeoUtils {
  /// Calcula la distancia en kilómetros entre dos coordenadas usando la fórmula de Haversine
  static double calcularDistanciaHaversine(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Radio de la Tierra en km
    final double dLat = _gradosARadianes(lat2 - lat1);
    final double dLon = _gradosARadianes(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_gradosARadianes(lat1)) * math.cos(_gradosARadianes(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return r * c;
  }

  static double _gradosARadianes(double grados) {
    return grados * math.pi / 180;
  }

  /// Verificación rápida (sin red) de que un punto cae dentro del territorio
  /// de Ecuador: caja continental + caja de Galápagos. Es un pre-filtro y
  /// respaldo offline de la validación fina con Nominatim (country_code).
  static bool dentroDeEcuador(double lat, double lng) {
    final continental = lat >= -5.05 && lat <= 1.70 && lng >= -81.20 && lng <= -75.15;
    final galapagos = lat >= -1.50 && lat <= 1.70 && lng >= -92.10 && lng <= -89.00;
    return continental || galapagos;
  }

  /// Decodifica un polyline codificado (algoritmo de Google, precisión 5,
  /// el mismo formato que devuelve OSRM) a una lista de pares [lat, lng].
  ///
  /// Importante: no usa el operador `~` para el signo porque en la web
  /// (dart2js) los operadores bit a bit trabajan con enteros sin signo de
  /// 32 bits y los deltas negativos se corrompen (latitudes de millones).
  static List<List<double>> decodificarPolyline(String polylineCodificado) {
    final puntos = <List<double>>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polylineCodificado.length) {
      final (deltaLat, indexTrasLat) = _decodificarValor(polylineCodificado, index);
      final (deltaLng, indexTrasLng) = _decodificarValor(polylineCodificado, indexTrasLat);
      index = indexTrasLng;
      lat += deltaLat;
      lng += deltaLng;
      puntos.add([lat / 1e5, lng / 1e5]);
    }

    return puntos;
  }

  static (int, int) _decodificarValor(String cadena, int index) {
    int resultado = 0;
    int shift = 0;
    int byte;
    do {
      byte = cadena.codeUnitAt(index++) - 63;
      resultado += (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    // Equivalente a ~(resultado >> 1) pero seguro en web
    final int valor = resultado >> 1;
    return ((resultado & 1) != 0 ? -(valor + 1) : valor, index);
  }
}
