import '../../repositories/pedido_repository.dart';

class MarcarEntregadoUseCase {
  final PedidoRepository repository;

  MarcarEntregadoUseCase(this.repository);

  Future<void> call(String pedidoId, String repartidorId) {
    return repository.marcarEntregado(pedidoId, repartidorId);
  }
}
