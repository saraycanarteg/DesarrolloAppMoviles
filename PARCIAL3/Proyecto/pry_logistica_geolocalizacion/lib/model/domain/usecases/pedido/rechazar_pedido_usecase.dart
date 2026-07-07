import '../../repositories/pedido_repository.dart';

class RechazarPedidoUseCase {
  final PedidoRepository repository;

  RechazarPedidoUseCase(this.repository);

  Future<void> call(String repartidorId, String pedidoId, {bool reintentarAutomatico = false}) {
    return repository.rechazarPedido(repartidorId, pedidoId, reintentarAutomatico: reintentarAutomatico);
  }
}
