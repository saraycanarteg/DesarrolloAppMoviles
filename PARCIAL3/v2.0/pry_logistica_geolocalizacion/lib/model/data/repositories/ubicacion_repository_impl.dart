import '../../domain/entities/ubicacion_entity.dart';
import '../../domain/repositories/ubicacion_repository.dart';
import '../datasources/location_datasource.dart';
import '../datasources/database_remote_datasource.dart';
import '../models/ubicacion_model.dart';

class UbicacionRepositoryImpl implements UbicacionRepository {
  final LocationDataSource locationDataSource;
  final DatabaseRemoteDataSource databaseDataSource;

  UbicacionRepositoryImpl(this.locationDataSource, this.databaseDataSource);

  @override
  Stream<UbicacionEntity> observarPosicionGps(String repartidorId) {
    return locationDataSource.observarPosicion(repartidorId);
  }

  @override
  Future<UbicacionEntity> obtenerPosicionActual(String repartidorId) {
    return locationDataSource.obtenerPosicionActual(repartidorId);
  }

  @override
  Future<void> actualizarUbicacion(UbicacionEntity ubicacion) {
    final modelo = UbicacionModel(
      repartidorId: ubicacion.repartidorId,
      lat: ubicacion.lat,
      lng: ubicacion.lng,
      heading: ubicacion.heading,
      speed: ubicacion.speed,
      accuracy: ubicacion.accuracy,
      timestamp: ubicacion.timestamp,
    );
    return databaseDataSource.actualizarUbicacion(ubicacion.repartidorId, modelo);
  }

  @override
  Stream<UbicacionEntity?> observarUbicacionRepartidor(String repartidorId) {
    return databaseDataSource.observarUbicacion(repartidorId);
  }
}
