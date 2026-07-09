/// Resultado de geocodificar una dirección (texto → coordenadas) o de
/// geocodificación inversa (coordenadas → texto).
class DireccionEntity {
  final String descripcion;
  final double lat;
  final double lng;

  /// Código ISO 3166-1 alfa-2 en minúsculas (ej. 'ec' para Ecuador).
  /// Null si el servicio no pudo determinar el país.
  final String? codigoPais;

  const DireccionEntity({
    required this.descripcion,
    required this.lat,
    required this.lng,
    this.codigoPais,
  });

  bool get esEcuador => codigoPais == 'ec';
}
