import '../../repositories/pedido_repository.dart';

class AceptarPedidoUseCase {
  final PedidoRepository repository;

  AceptarPedidoUseCase(this.repository);

  Future<void> call(String repartidorId, String pedidoId) {
    return repository.aceptarPedido(repartidorId, pedidoId);
  }
}
