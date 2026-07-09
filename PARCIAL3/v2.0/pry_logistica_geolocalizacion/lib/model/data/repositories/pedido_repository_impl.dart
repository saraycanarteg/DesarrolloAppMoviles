import '../../domain/entities/pedido_entity.dart';
import '../../domain/entities/repartidor_entity.dart';
import '../../domain/repositories/pedido_repository.dart';
import '../datasources/database_remote_datasource.dart';
import '../models/pedido_model.dart';

class PedidoRepositoryImpl implements PedidoRepository {
  final DatabaseRemoteDataSource remoteDataSource;

  PedidoRepositoryImpl(this.remoteDataSource);

  @override
  Future<PedidoEntity> crearPedido(PedidoEntity pedido) {
    final modelo = PedidoModel(
      id: pedido.id,
      clienteNombre: pedido.clienteNombre,
      direccionOrigen: pedido.direccionOrigen,
      latOrigen: pedido.latOrigen,
      lngOrigen: pedido.lngOrigen,
      direccionDestino: pedido.direccionDestino,
      latDestino: pedido.latDestino,
      lngDestino: pedido.lngDestino,
      estado: pedido.estado,
      repartidorId: pedido.repartidorId,
      creadoPor: pedido.creadoPor,
      creadoEn: pedido.creadoEn,
      asignadoEn: pedido.asignadoEn,
      enRutaEn: pedido.enRutaEn,
      recogidoEn: pedido.recogidoEn,
      enRutaClienteEn: pedido.enRutaClienteEn,
      entregadoEn: pedido.entregadoEn,
    );
    return remoteDataSource.crearPedido(modelo);
  }

  @override
  Stream<List<RepartidorEntity>> observarRepartidores() {
    return remoteDataSource.observarRepartidores();
  }

  @override
  Future<void> actualizarRepartidor(
    String uid, {
    required String telefono,
    required String email,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  }) {
    return remoteDataSource.actualizarRepartidor(
      uid,
      telefono: telefono,
      email: email,
      vehiculoTipo: vehiculoTipo,
      vehiculoMarca: vehiculoMarca,
      vehiculoPlaca: vehiculoPlaca,
    );
  }

  @override
  Future<void> eliminarRepartidor(String uid) {
    return remoteDataSource.eliminarRepartidor(uid);
  }

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

  @override
  Future<void> iniciarRuta(String pedidoId) {
    return remoteDataSource.iniciarRuta(pedidoId);
  }

  @override
  Future<void> marcarRecogido(String pedidoId) {
    return remoteDataSource.marcarRecogido(pedidoId);
  }

  @override
  Future<void> iniciarRutaCliente(String pedidoId) {
    return remoteDataSource.iniciarRutaCliente(pedidoId);
  }

  @override
  Future<void> marcarEntregado(String pedidoId, String repartidorId) {
    return remoteDataSource.marcarEntregado(pedidoId, repartidorId);
  }
}
