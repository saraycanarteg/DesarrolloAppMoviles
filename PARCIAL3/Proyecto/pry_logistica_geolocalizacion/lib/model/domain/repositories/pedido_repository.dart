import '../entities/pedido_entity.dart';

abstract class PedidoRepository {
  Future<void> asignarRepartidor(String pedidoId, {String? repartidorManualId});
  Future<void> aceptarPedido(String repartidorId, String pedidoId);
  Future<void> rechazarPedido(String repartidorId, String pedidoId, {bool reintentarAutomatico = false});
  Stream<PedidoEntity?> observarPedidoPropuesto(String repartidorId);
  Stream<List<PedidoEntity>> observarTodosLosPedidos();
}
