import '../../entities/ubicacion_entity.dart';
import '../../repositories/ubicacion_repository.dart';

/// Permite al administrador (o a cualquier pantalla de mapa) seguir en vivo
/// la ubicación que un repartidor publica en Firebase RTDB.
class ObservarUbicacionRepartidorUseCase {
  final UbicacionRepository repository;

  ObservarUbicacionRepartidorUseCase(this.repository);

  Stream<UbicacionEntity?> call(String repartidorId) {
    return repository.observarUbicacionRepartidor(repartidorId);
  }
}
