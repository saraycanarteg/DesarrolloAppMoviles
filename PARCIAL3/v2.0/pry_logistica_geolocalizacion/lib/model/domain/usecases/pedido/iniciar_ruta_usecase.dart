import '../../repositories/pedido_repository.dart';

class IniciarRutaUseCase {
  final PedidoRepository repository;

  IniciarRutaUseCase(this.repository);

  Future<void> call(String pedidoId) {
    return repository.iniciarRuta(pedidoId);
  }
}
