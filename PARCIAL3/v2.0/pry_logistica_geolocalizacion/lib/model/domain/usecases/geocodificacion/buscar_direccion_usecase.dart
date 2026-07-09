import '../../entities/direccion_entity.dart';
import '../../repositories/geocodificacion_repository.dart';

class BuscarDireccionUseCase {
  final GeocodificacionRepository repository;

  BuscarDireccionUseCase(this.repository);

  Future<DireccionEntity?> call(String consulta) {
    return repository.buscarDireccion(consulta);
  }
}
