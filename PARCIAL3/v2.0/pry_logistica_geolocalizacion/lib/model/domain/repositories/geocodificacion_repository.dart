import '../entities/direccion_entity.dart';

abstract class GeocodificacionRepository {
  /// Busca una dirección escrita por el usuario (restringida a Ecuador).
  /// Devuelve null si no existe en el mapa.
  Future<DireccionEntity?> buscarDireccion(String consulta);

  /// Geocodificación inversa: obtiene la dirección legible de un punto
  /// tocado en el mapa. Devuelve null si el punto no corresponde a ningún
  /// lugar conocido (p. ej. mar abierto).
  Future<DireccionEntity?> obtenerDireccion(double lat, double lng);
}
