import '../../repositories/pedido_repository.dart';
import '../../entities/pedido_entity.dart';

class ObservarPedidoPropuestoUseCase {
  final PedidoRepository repository;

  ObservarPedidoPropuestoUseCase(this.repository);

  Stream<PedidoEntity?> call(String repartidorId) {
    return repository.observarPedidoPropuesto(repartidorId);
  }
}
