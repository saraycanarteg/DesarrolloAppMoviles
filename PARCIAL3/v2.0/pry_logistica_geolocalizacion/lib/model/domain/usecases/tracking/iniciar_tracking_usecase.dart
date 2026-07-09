import '../../entities/ubicacion_entity.dart';
import '../../repositories/ubicacion_repository.dart';

/// Escucha el GPS del dispositivo y publica cada posición en Firebase RTDB,
/// devolviendo el stream para que la UI también pueda reaccionar.
class IniciarTrackingUseCase {
  final UbicacionRepository repository;

  IniciarTrackingUseCase(this.repository);

  Stream<UbicacionEntity> call(String repartidorId) {
    return repository.observarPosicionGps(repartidorId).asyncMap((ubicacion) async {
      await repository.actualizarUbicacion(ubicacion);
      return ubicacion;
    });
  }
}
