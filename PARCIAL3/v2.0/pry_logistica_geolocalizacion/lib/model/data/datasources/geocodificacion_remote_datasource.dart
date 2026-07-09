import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/direccion_model.dart';

/// Consumo de la API REST de Nominatim (geocodificador de OpenStreetMap,
/// sin API key, igual que las teselas OSM y el enrutador OSRM del proyecto).
/// - search: texto → coordenadas, restringido a Ecuador (countrycodes=ec).
/// - reverse: coordenadas → dirección legible + país (para validar que el
///   punto tocado en el mapa esté dentro de Ecuador).
class GeocodificacionRemoteDataSource {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Nominatim exige identificar la aplicación en cada petición.
  static const Map<String, String> _headers = {
    'User-Agent': 'pry_logistica_geolocalizacion/1.0 (app academica Flutter)',
  };

  final http.Client _client;

  GeocodificacionRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  Future<DireccionModel?> buscarDireccion(String consulta) async {
    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
      'q': consulta,
      'format': 'jsonv2',
      'limit': '1',
      'countrycodes': 'ec',
      'addressdetails': '1',
      'accept-language': 'es',
    });

    final json = await _get(uri);
    if (json is! List || json.isEmpty) return null;
    return DireccionModel.fromNominatim(json.first as Map<String, dynamic>);
  }

  Future<DireccionModel?> obtenerDireccion(double lat, double lng) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
      'lat': '$lat',
      'lon': '$lng',
      'format': 'jsonv2',
      'addressdetails': '1',
      'zoom': '17',
      'accept-language': 'es',
    });

    final json = await _get(uri);
    // Nominatim devuelve {"error": "Unable to geocode"} para puntos sin
    // dirección (p. ej. mar abierto).
    if (json is! Map<String, dynamic> || json.containsKey('error')) return null;
    return DireccionModel.fromNominatim(json);
  }

  Future<dynamic> _get(Uri uri) async {
    final http.Response respuesta;
    try {
      respuesta = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
    } catch (e) {
      throw Exception('No se pudo conectar con el servicio de direcciones (Nominatim): $e');
    }

    if (respuesta.statusCode != 200) {
      throw Exception('El servicio de direcciones respondió con error ${respuesta.statusCode}');
    }
    return jsonDecode(utf8.decode(respuesta.bodyBytes));
  }
}
