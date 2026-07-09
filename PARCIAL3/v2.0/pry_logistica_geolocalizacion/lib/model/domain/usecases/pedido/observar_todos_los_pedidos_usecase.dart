import '../../repositories/pedido_repository.dart';
import '../../entities/pedido_entity.dart';

class ObservarTodosLosPedidosUseCase {
  final PedidoRepository repository;

  ObservarTodosLosPedidosUseCase(this.repository);

  Stream<List<PedidoEntity>> call() {
    return repository.observarTodosLosPedidos();
  }
}
