import '../../entities/pedido_entity.dart';
import '../../repositories/pedido_repository.dart';

class CrearPedidoUseCase {
  final PedidoRepository repository;

  CrearPedidoUseCase(this.repository);

  Future<PedidoEntity> call(PedidoEntity pedido) {
    return repository.crearPedido(pedido);
  }
}
