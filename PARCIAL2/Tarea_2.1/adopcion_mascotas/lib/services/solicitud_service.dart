import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/solicitud.dart';

class SolicitudService {
  final String baseUrl = 'http://127.0.0.1:8000/solicitudes';

  Future<List<Solicitud>> getAll() async {
    final resp = await http.get(Uri.parse(baseUrl));
    if (resp.statusCode != 200) throw Exception('Error al cargar solicitudes');
    final List data = jsonDecode(resp.body);
    return data.map((e) => Solicitud.fromJson(e)).toList();
  }

  Future<Solicitud> create(Solicitud sol) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sol.toJson()),
    );
    if (resp.statusCode != 201) {
      final err = jsonDecode(resp.body);
      throw Exception(err['detail'] ?? 'Error al crear solicitud');
    }
    return Solicitud.fromJson(jsonDecode(resp.body));
  }

  Future<Solicitud> aprobar(int id) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'aprobada': true}),
    );
    if (resp.statusCode != 200) throw Exception('Error al aprobar');
    return Solicitud.fromJson(jsonDecode(resp.body));
  }

  Future<void> delete(int id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/$id'));
    if (resp.statusCode != 204) throw Exception('Error al eliminar solicitud');
  }
}