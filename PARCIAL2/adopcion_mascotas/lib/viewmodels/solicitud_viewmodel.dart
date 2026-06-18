import 'package:flutter/material.dart';
import '../models/solicitud.dart';
import '../services/solicitud_service.dart';

class SolicitudViewmodel extends ChangeNotifier {
  final SolicitudService _service = SolicitudService();

  List<Solicitud> solicitudes  = [];
  bool            loading      = false;
  String?         errorMessage;

  Future<void> cargarSolicitudes() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      solicitudes = await _service.getAll();
    } catch (e) {
      errorMessage = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> crearSolicitud(Solicitud sol) async {
    try {
      final nueva = await _service.create(sol);
      solicitudes.insert(0, nueva);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> aprobarSolicitud(int id) async {
    try {
      final actualizada = await _service.aprobar(id);
      final idx = solicitudes.indexWhere((s) => s.id == id);
      if (idx != -1) solicitudes[idx] = actualizada;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarSolicitud(int id) async {
    try {
      await _service.delete(id);
      solicitudes.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}