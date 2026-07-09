import '../../entities/ruta_entity.dart';
import '../../repositories/ruta_repository.dart';

/// Ruta en carretera entre dos puntos arbitrarios (sin caché), usada para
/// el tramo dinámico repartidor→tienda o repartidor→cliente.
class CalcularRutaDirectaUseCase {
  final RutaRepository repository;

  CalcularRutaDirectaUseCase(this.repository);

  Future<RutaEntity> call({
    required double latOrigen,
    required double lngOrigen,
    required double latDestino,
    required double lngDestino,
  }) {
    return repository.calcularRutaDirecta(
      latOrigen: latOrigen,
      lngOrigen: lngOrigen,
      latDestino: latDestino,
      lngDestino: lngDestino,
    );
  }
}
