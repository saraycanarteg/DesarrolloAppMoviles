import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/notificaciones_service.dart';
import '../model/domain/usecases/pedido/asignar_repartidor_usecase.dart';
import '../model/domain/usecases/pedido/crear_pedido_usecase.dart';
import '../model/domain/usecases/pedido/observar_repartidores_usecase.dart';
import '../model/domain/usecases/pedido/observar_todos_los_pedidos_usecase.dart';
import '../model/domain/entities/pedido_entity.dart';
import '../model/domain/entities/repartidor_entity.dart';

enum PedidoViewModelState { idle, loading, success, error }

class PedidoViewModel extends ChangeNotifier {
  final AsignarRepartidorUseCase _asignarRepartidorUseCase;
  final ObservarTodosLosPedidosUseCase _observarTodosLosPedidosUseCase;
  final ObservarRepartidoresUseCase _observarRepartidoresUseCase;
  final CrearPedidoUseCase _crearPedidoUseCase;
  final NotificacionesService? _notificaciones;

  PedidoViewModelState _state = PedidoViewModelState.idle;
  PedidoViewModelState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAsignacionAutomatica = true;
  bool get isAsignacionAutomatica => _isAsignacionAutomatica;

  PedidoViewModel(
    this._asignarRepartidorUseCase,
    this._observarTodosLosPedidosUseCase,
    this._observarRepartidoresUseCase,
    this._crearPedidoUseCase, {
    this._notificaciones,
  });

  Stream<List<PedidoEntity>> get todosLosPedidos => _observarTodosLosPedidosUseCase();

  Stream<List<RepartidorEntity>> get repartidores => _observarRepartidoresUseCase();

  // ===== Notificaciones del administrador (entrega confirmada) =====

  StreamSubscription<List<PedidoEntity>>? _subEntregas;
  final Map<String, EstadoPedido> _estadosPrevios = {};
  bool _primerEventoEntregas = true;

  /// Observa los pedidos y notifica al administrador cuando alguno pasa a
  /// "entregado". El primer evento del stream solo carga el estado inicial
  /// (para no notificar entregas viejas al abrir la app).
  void iniciarNotificacionesEntregas() {
    if (_notificaciones == null || _subEntregas != null) return;

    _subEntregas = _observarTodosLosPedidosUseCase().listen((pedidos) {
      for (final p in pedidos) {
        final previo = _estadosPrevios[p.id];
        final recienEntregado = p.estado == EstadoPedido.entregado &&
            previo != null &&
            previo != EstadoPedido.entregado;

        if (!_primerEventoEntregas && recienEntregado) {
          _notificaciones.mostrar(
            titulo: 'Entrega confirmada',
            cuerpo: '${p.repartidorNombre ?? 'El repartidor'} entregó el '
                'pedido de ${p.clienteNombre}.',
          );
        }
        _estadosPrevios[p.id] = p.estado;
      }
      _primerEventoEntregas = false;
    });
  }

  void detenerNotificacionesEntregas() {
    _subEntregas?.cancel();
    _subEntregas = null;
    _estadosPrevios.clear();
    _primerEventoEntregas = true;
  }

  @override
  void dispose() {
    _subEntregas?.cancel();
    super.dispose();
  }

  void toggleAsignacionAutomatica(bool value) {
    _isAsignacionAutomatica = value;
    notifyListeners();
  }

  Future<void> asignarPedido(String pedidoId, {String? repartidorManualId}) async {
    _state = PedidoViewModelState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_isAsignacionAutomatica) {
        await _asignarRepartidorUseCase(pedidoId);
      } else {
        if (repartidorManualId == null || repartidorManualId.isEmpty) {
          throw Exception('Debes seleccionar un repartidor para asignación manual');
        }
        await _asignarRepartidorUseCase(pedidoId, repartidorManualId: repartidorManualId);
      }
      _state = PedidoViewModelState.success;
    } catch (e) {
      _state = PedidoViewModelState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Crea un pedido nuevo en estado "pendiente". Devuelve true si se guardó.
  Future<bool> crearPedido({
    required String clienteNombre,
    required String direccionOrigen,
    required double latOrigen,
    required double lngOrigen,
    required String direccionDestino,
    required double latDestino,
    required double lngDestino,
    required String creadoPor,
  }) async {
    _state = PedidoViewModelState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _crearPedidoUseCase(PedidoEntity(
        id: '', // lo genera Firebase (push)
        clienteNombre: clienteNombre,
        direccionOrigen: direccionOrigen,
        latOrigen: latOrigen,
        lngOrigen: lngOrigen,
        direccionDestino: direccionDestino,
        latDestino: latDestino,
        lngDestino: lngDestino,
        estado: EstadoPedido.pendiente,
        repartidorId: null,
        creadoPor: creadoPor,
        creadoEn: DateTime.now().millisecondsSinceEpoch,
      ));
      _state = PedidoViewModelState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = PedidoViewModelState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
