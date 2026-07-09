import '../../repositories/pedido_repository.dart';

class AsignarRepartidorUseCase {
  final PedidoRepository repository;

  AsignarRepartidorUseCase(this.repository);

  Future<void> call(String pedidoId, {String? repartidorManualId}) {
    return repository.asignarRepartidor(pedidoId, repartidorManualId: repartidorManualId);
  }
}
