import 'package:geolocator/geolocator.dart';
import '../models/ubicacion_model.dart';

/// Acceso al hardware GPS del dispositivo (sensores de ubicación).
/// Encapsula geolocator: verificación de servicio, permisos y stream de posición.
class LocationDataSource {
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5, // metros mínimos entre reportes
  );

  /// Verifica que el GPS esté encendido y que el usuario haya concedido permisos.
  /// Lanza una excepción con mensaje entendible si algo falta.
  Future<void> verificarPermisos() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      throw Exception('El GPS está desactivado. Actívalo para iniciar el seguimiento.');
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado.');
    }
    if (permiso == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado permanentemente. Habilítalo desde los ajustes del sistema.');
    }
  }

  Future<UbicacionModel> obtenerPosicionActual(String repartidorId) async {
    await verificarPermisos();
    final posicion = await Geolocator.getCurrentPosition(locationSettings: _settings);
    return _aModelo(repartidorId, posicion);
  }

  /// Stream continuo de posiciones GPS convertidas al modelo del dominio.
  /// Verifica servicio y permisos antes de empezar a emitir.
  Stream<UbicacionModel> observarPosicion(String repartidorId) async* {
    await verificarPermisos();
    yield* Geolocator.getPositionStream(locationSettings: _settings)
        .map((posicion) => _aModelo(repartidorId, posicion));
  }

  UbicacionModel _aModelo(String repartidorId, Position posicion) {
    return UbicacionModel(
      repartidorId: repartidorId,
      lat: posicion.latitude,
      lng: posicion.longitude,
      heading: posicion.heading,
      speed: posicion.speed,
      accuracy: posicion.accuracy,
      timestamp: posicion.timestamp.millisecondsSinceEpoch,
    );
  }
}
