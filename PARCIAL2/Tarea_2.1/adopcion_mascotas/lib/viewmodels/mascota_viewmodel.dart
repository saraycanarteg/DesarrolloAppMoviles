import 'package:flutter/material.dart';
import '../models/mascota.dart';
import '../services/mascota_service.dart';

class MascotaViewmodel extends ChangeNotifier {
  final MascotaService _service = MascotaService();

  List<Mascota> mascotas   = [];
  bool          loading    = false;
  String?       errorMessage;

  Future<void> cargarMascotas() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      mascotas = await _service.getAll();
    } catch (e) {
      errorMessage = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> crearMascota(Mascota mascota) async {
    try {
      final nueva = await _service.create(mascota);
      mascotas.insert(0, nueva);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarMascota(int id, Mascota mascota) async {
    try {
      final actualizada = await _service.update(id, mascota);
      final idx = mascotas.indexWhere((m) => m.id == id);
      if (idx != -1) mascotas[idx] = actualizada;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarMascota(int id) async {
    try {
      await _service.delete(id);
      mascotas.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}