import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mascota.dart';

class MascotaService {
  final String baseUrl = 'http://10.40.57.172:8000/mascotas/';// emulador Android

  Future<List<Mascota>> getAll() async {
    final resp = await http.get(Uri.parse(baseUrl));
    if (resp.statusCode != 200) throw Exception('Error al cargar mascotas');
    final List data = jsonDecode(resp.body);
    return data.map((e) => Mascota.fromJson(e)).toList();
  }

  Future<Mascota> getById(int id) async {
    final resp = await http.get(Uri.parse('$baseUrl/$id'));
    if (resp.statusCode != 200) throw Exception('Mascota no encontrada');
    return Mascota.fromJson(jsonDecode(resp.body));
  }

  Future<Mascota> create(Mascota mascota) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(mascota.toJson()),
    );
    if (resp.statusCode != 201) {
      final err = jsonDecode(resp.body);
      throw Exception(err['detail'] ?? 'Error al crear mascota');
    }
    return Mascota.fromJson(jsonDecode(resp.body));
  }

  Future<Mascota> update(int id, Mascota mascota) async {
    final resp = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(mascota.toJson()),
    );
    if (resp.statusCode != 200) {
      final err = jsonDecode(resp.body);
      throw Exception(err['detail'] ?? 'Error al actualizar mascota');
    }
    return Mascota.fromJson(jsonDecode(resp.body));
  }

  Future<void> delete(int id) async {
    final resp = await http.delete(Uri.parse('$baseUrl$id'));
    if (resp.statusCode != 204) throw Exception('Error al eliminar mascota');
  }
}