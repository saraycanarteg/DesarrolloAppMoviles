import '../../entities/repartidor_entity.dart';
import '../../repositories/pedido_repository.dart';

class ObservarRepartidoresUseCase {
  final PedidoRepository repository;

  ObservarRepartidoresUseCase(this.repository);

  Stream<List<RepartidorEntity>> call() {
    return repository.observarRepartidores();
  }
}
