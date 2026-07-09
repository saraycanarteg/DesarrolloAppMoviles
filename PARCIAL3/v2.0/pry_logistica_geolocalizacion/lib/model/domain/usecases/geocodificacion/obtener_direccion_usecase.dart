import '../../entities/direccion_entity.dart';
import '../../repositories/geocodificacion_repository.dart';

class ObtenerDireccionUseCase {
  final GeocodificacionRepository repository;

  ObtenerDireccionUseCase(this.repository);

  Future<DireccionEntity?> call(double lat, double lng) {
    return repository.obtenerDireccion(lat, lng);
  }
}
