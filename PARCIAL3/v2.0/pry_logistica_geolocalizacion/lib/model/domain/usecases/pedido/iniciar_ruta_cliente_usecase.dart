import '../../repositories/pedido_repository.dart';

class IniciarRutaClienteUseCase {
  final PedidoRepository repository;

  IniciarRutaClienteUseCase(this.repository);

  Future<void> call(String pedidoId) {
    return repository.iniciarRutaCliente(pedidoId);
  }
}
