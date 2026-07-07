import 'package:flutter/foundation.dart';
import '../model/domain/usecases/pedido/asignar_repartidor_usecase.dart';
import '../model/domain/usecases/pedido/observar_todos_los_pedidos_usecase.dart';
import '../model/domain/entities/pedido_entity.dart';

enum PedidoViewModelState { idle, loading, success, error }

class PedidoViewModel extends ChangeNotifier {
  final AsignarRepartidorUseCase _asignarRepartidorUseCase;
  final ObservarTodosLosPedidosUseCase _observarTodosLosPedidosUseCase;

  PedidoViewModelState _state = PedidoViewModelState.idle;
  PedidoViewModelState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAsignacionAutomatica = true;
  bool get isAsignacionAutomatica => _isAsignacionAutomatica;

  PedidoViewModel(this._asignarRepartidorUseCase, this._observarTodosLosPedidosUseCase);

  Stream<List<PedidoEntity>> get todosLosPedidos => _observarTodosLosPedidosUseCase();

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
}
