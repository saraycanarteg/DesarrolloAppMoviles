import '../entities/ubicacion_entity.dart';

abstract class UbicacionRepository {
  /// Stream de posiciones del GPS del dispositivo (hardware).
  Stream<UbicacionEntity> observarPosicionGps(String repartidorId);

  /// Última posición conocida del dispositivo (una sola lectura).
  Future<UbicacionEntity> obtenerPosicionActual(String repartidorId);

  /// Publica la ubicación del repartidor en Firebase RTDB.
  Future<void> actualizarUbicacion(UbicacionEntity ubicacion);

  /// Observa en tiempo real la ubicación de un repartidor desde Firebase RTDB.
  Stream<UbicacionEntity?> observarUbicacionRepartidor(String repartidorId);
}
