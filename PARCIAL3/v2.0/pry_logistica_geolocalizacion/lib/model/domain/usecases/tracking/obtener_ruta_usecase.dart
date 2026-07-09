import '../../entities/pedido_entity.dart';
import '../../entities/ruta_entity.dart';
import '../../repositories/ruta_repository.dart';

class ObtenerRutaUseCase {
  final RutaRepository repository;

  ObtenerRutaUseCase(this.repository);

  Future<RutaEntity> call(PedidoEntity pedido) {
    return repository.obtenerRutaDePedido(pedido);
  }
}
