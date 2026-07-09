import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ruta_model.dart';

/// Consumo de la API REST de OSRM (Open Source Routing Machine) para calcular
/// la ruta en carretera entre el origen y el destino de un pedido.
/// Devuelve la geometría como polyline codificado (mismo algoritmo de Google).
class RutaRemoteDataSource {
  static const String _baseUrl = 'https://router.project-osrm.org';

  final http.Client _client;

  RutaRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<RutaModel> calcularRuta({
    required String pedidoId,
    required String repartidorId,
    required double latOrigen,
    required double lngOrigen,
    required double latDestino,
    required double lngDestino,
  }) async {
    // OSRM recibe las coordenadas como lng,lat (¡al revés que Google!)
    final uri = Uri.parse(
      '$_baseUrl/route/v1/driving/$lngOrigen,$latOrigen;$lngDestino,$latDestino'
      '?overview=full&geometries=polyline',
    );

    final http.Response respuesta;
    try {
      respuesta = await _client.get(uri).timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('No se pudo conectar con el servicio de rutas (OSRM): $e');
    }

    if (respuesta.statusCode != 200) {
      throw Exception('El servicio de rutas respondió con error ${respuesta.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(respuesta.body);
    if (json['code'] != 'Ok' || (json['routes'] as List).isEmpty) {
      throw Exception('OSRM no encontró una ruta entre el origen y el destino');
    }

    final ruta = json['routes'][0];
    return RutaModel(
      id: pedidoId, // la ruta se guarda con el mismo ID del pedido para búsqueda directa
      pedidoId: pedidoId,
      repartidorId: repartidorId,
      polylineCodificado: ruta['geometry'] as String,
      distanciaKm: (ruta['distance'] as num).toDouble() / 1000.0,
      duracionMin: (ruta['duration'] as num).toDouble() / 60.0,
    );
  }
}
