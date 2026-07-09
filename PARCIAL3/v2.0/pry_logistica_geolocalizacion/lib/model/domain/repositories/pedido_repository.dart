import '../entities/pedido_entity.dart';
import '../entities/repartidor_entity.dart';

abstract class PedidoRepository {
  Future<PedidoEntity> crearPedido(PedidoEntity pedido);
  Stream<List<RepartidorEntity>> observarRepartidores();

  /// Edición (admin) de los datos de contacto y del vehículo de un repartidor.
  Future<void> actualizarRepartidor(
    String uid, {
    required String telefono,
    required String email,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  });

  /// Eliminación (admin) del registro de un repartidor.
  Future<void> eliminarRepartidor(String uid);

  Future<void> asignarRepartidor(String pedidoId, {String? repartidorManualId});
  Future<void> aceptarPedido(String repartidorId, String pedidoId);
  Future<void> rechazarPedido(String repartidorId, String pedidoId, {bool reintentarAutomatico = false});
  Stream<PedidoEntity?> observarPedidoPropuesto(String repartidorId);
  Stream<List<PedidoEntity>> observarTodosLosPedidos();
  Future<void> iniciarRuta(String pedidoId);
  Future<void> marcarRecogido(String pedidoId);
  Future<void> iniciarRutaCliente(String pedidoId);
  Future<void> marcarEntregado(String pedidoId, String repartidorId);
}
