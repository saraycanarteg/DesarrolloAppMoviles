import '../../domain/entities/direccion_entity.dart';
import '../../domain/repositories/geocodificacion_repository.dart';
import '../datasources/geocodificacion_remote_datasource.dart';

class GeocodificacionRepositoryImpl implements GeocodificacionRepository {
  final GeocodificacionRemoteDataSource remoteDataSource;

  GeocodificacionRepositoryImpl(this.remoteDataSource);

  @override
  Future<DireccionEntity?> buscarDireccion(String consulta) {
    return remoteDataSource.buscarDireccion(consulta);
  }

  @override
  Future<DireccionEntity?> obtenerDireccion(double lat, double lng) {
    return remoteDataSource.obtenerDireccion(lat, lng);
  }
}
