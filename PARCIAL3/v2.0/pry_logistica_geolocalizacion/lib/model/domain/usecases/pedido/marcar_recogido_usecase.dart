import '../../repositories/pedido_repository.dart';

class MarcarRecogidoUseCase {
  final PedidoRepository repository;

  MarcarRecogidoUseCase(this.repository);

  Future<void> call(String pedidoId) {
    return repository.marcarRecogido(pedidoId);
  }
}
