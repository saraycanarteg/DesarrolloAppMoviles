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
}
