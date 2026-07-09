import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/notificaciones_service.dart';
import '../model/domain/entities/pedido_entity.dart';
import '../model/domain/usecases/pedido/observar_pedido_propuesto_usecase.dart';
import '../model/domain/usecases/pedido/aceptar_pedido_usecase.dart';
import '../model/domain/usecases/pedido/rechazar_pedido_usecase.dart';

class RepartidorViewModel extends ChangeNotifier {
  final ObservarPedidoPropuestoUseCase _observarPedidoPropuestoUseCase;
  final AceptarPedidoUseCase _aceptarPedidoUseCase;
  final RechazarPedidoUseCase _rechazarPedidoUseCase;
  final NotificacionesService? _notificaciones;

  StreamSubscription<PedidoEntity?>? _pedidoSubscription;
  PedidoEntity? _pedidoPropuesto;
  PedidoEntity? get pedidoPropuesto => _pedidoPropuesto;
  
  PedidoEntity? _pedidoActual;
  PedidoEntity? get pedidoActual => _pedidoActual;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  RepartidorViewModel(
    this._observarPedidoPropuestoUseCase,
    this._aceptarPedidoUseCase,
    this._rechazarPedidoUseCase, {
    this._notificaciones,
  });


  void iniciarEscucha(String repartidorId) {
    _pedidoSubscription?.cancel();
    _pedidoSubscription = _observarPedidoPropuestoUseCase(repartidorId).listen((pedido) {
      debugPrint('DEBUG STREAM: Recibido pedido en ViewModel. Es null? ${pedido == null}. Estado: ${pedido?.estado}');
      
      if (pedido != null) {
        if (pedido.estado == EstadoPedido.esperandoConfirmacion) {
          // Notificar solo cuando la propuesta es nueva (no en cada refresco)
          if (_pedidoPropuesto?.id != pedido.id) {
            _notificaciones?.mostrar(
              titulo: 'Nuevo pedido propuesto',
              cuerpo: 'Entrega para ${pedido.clienteNombre}: '
                  '${pedido.direccionOrigen} → ${pedido.direccionDestino}',
            );
          }
          _pedidoPropuesto = pedido;
          _pedidoActual = null;
        } else {
          _pedidoPropuesto = null;
          _pedidoActual = pedido;
        }
      } else {
        _pedidoPropuesto = null;
        _pedidoActual = null;
      }
      notifyListeners();
    });
  }

  Future<void> aceptarPedidoPropuesto(String repartidorId) async {
    if (_pedidoPropuesto == null) return;
    _isProcessing = true;
    notifyListeners();

    try {
      await _aceptarPedidoUseCase(repartidorId, _pedidoPropuesto!.id);
      _pedidoPropuesto = null; // Quitar del UI
    } catch (e) {
      debugPrint('Error aceptando pedido: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> rechazarPedidoPropuesto(String repartidorId) async {
    if (_pedidoPropuesto == null) return;
    _isProcessing = true;
    notifyListeners();

    try {
      // Reintentar automático siempre es true en el flujo estándar si rechazó
      await _rechazarPedidoUseCase(repartidorId, _pedidoPropuesto!.id, reintentarAutomatico: true);
      _pedidoPropuesto = null; // Quitar del UI
    } catch (e) {
      debugPrint('Error rechazando pedido: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pedidoSubscription?.cancel();
    super.dispose();
  }
}
