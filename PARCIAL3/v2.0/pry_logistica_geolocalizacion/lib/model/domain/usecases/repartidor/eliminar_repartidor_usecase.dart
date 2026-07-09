import '../../repositories/pedido_repository.dart';

/// Caso de uso del administrador: eliminar el registro de un repartidor.
class EliminarRepartidorUseCase {
  final PedidoRepository repository;

  EliminarRepartidorUseCase(this.repository);

  Future<void> call(String uid) {
    return repository.eliminarRepartidor(uid);
  }
}
