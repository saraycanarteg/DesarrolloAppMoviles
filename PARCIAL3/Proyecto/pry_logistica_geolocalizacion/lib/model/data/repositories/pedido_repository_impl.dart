import '../../domain/entities/pedido_entity.dart';
import '../../domain/repositories/pedido_repository.dart';
import '../datasources/database_remote_datasource.dart';

class PedidoRepositoryImpl implements PedidoRepository {
  final DatabaseRemoteDataSource remoteDataSource;

  PedidoRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> asignarRepartidor(String pedidoId, {String? repartidorManualId}) {
    return remoteDataSource.asignarRepartidor(pedidoId, repartidorManualId: repartidorManualId);
  }

  @override
  Future<void> aceptarPedido(String repartidorId, String pedidoId) {
    return remoteDataSource.aceptarPedido(repartidorId, pedidoId);
  }

  @override
  Future<void> rechazarPedido(String repartidorId, String pedidoId, {bool reintentarAutomatico = false}) {
    return remoteDataSource.rechazarPedido(repartidorId, pedidoId, reintentarAutomatico: reintentarAutomatico);
  }

  @override
  Stream<PedidoEntity?> observarPedidoPropuesto(String repartidorId) {
    return remoteDataSource.observarPedidoPropuesto(repartidorId);
  }

  @override
  Stream<List<PedidoEntity>> observarTodosLosPedidos() {
    return remoteDataSource.observarTodosLosPedidos();
  }
}
