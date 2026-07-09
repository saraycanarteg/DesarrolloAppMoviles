import 'package:flutter/foundation.dart';
import '../model/domain/usecases/auth/registrar_repartidor_usecase.dart';
import '../model/domain/usecases/repartidor/actualizar_repartidor_usecase.dart';
import '../model/domain/usecases/repartidor/eliminar_repartidor_usecase.dart';

enum GestionRepartidorState { idle, loading, success, error }

/// Estado del módulo del administrador para dar de alta, editar y
/// eliminar repartidores.
class GestionRepartidorViewModel extends ChangeNotifier {
  final RegistrarRepartidorUseCase _registrarRepartidorUseCase;
  final ActualizarRepartidorUseCase _actualizarRepartidorUseCase;
  final EliminarRepartidorUseCase _eliminarRepartidorUseCase;

  GestionRepartidorViewModel(
    this._registrarRepartidorUseCase,
    this._actualizarRepartidorUseCase,
    this._eliminarRepartidorUseCase,
  );

  GestionRepartidorState _state = GestionRepartidorState.idle;
  GestionRepartidorState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Descarta el estado/error de la operación anterior. Llamar al abrir los
  /// formularios de alta y edición: el provider es global y un error viejo
  /// (p. ej. de una eliminación) no debe aparecer en la pantalla nueva.
  void limpiar() {
    if (_state == GestionRepartidorState.idle && _errorMessage == null) return;
    _state = GestionRepartidorState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Registra un repartidor nuevo. Devuelve true si se creó correctamente;
  /// si la cédula o el correo ya existen, deja el error en [errorMessage].
  Future<bool> registrarRepartidor({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  }) {
    return _ejecutar(() => _registrarRepartidorUseCase(
          nombre: nombre,
          cedula: cedula,
          telefono: telefono,
          email: email,
          password: password,
          vehiculoTipo: vehiculoTipo,
          vehiculoMarca: vehiculoMarca,
          vehiculoPlaca: vehiculoPlaca,
        ));
  }

  /// Edita el teléfono, correo y vehículo de un repartidor existente.
  Future<bool> actualizarRepartidor(
    String uid, {
    required String telefono,
    required String email,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  }) {
    return _ejecutar(() => _actualizarRepartidorUseCase(
          uid,
          telefono: telefono,
          email: email,
          vehiculoTipo: vehiculoTipo,
          vehiculoMarca: vehiculoMarca,
          vehiculoPlaca: vehiculoPlaca,
        ));
  }

  /// Elimina el registro de un repartidor. Devuelve true si se eliminó.
  Future<bool> eliminarRepartidor(String uid) {
    return _ejecutar(() => _eliminarRepartidorUseCase(uid));
  }

  Future<bool> _ejecutar(Future<void> Function() operacion) async {
    _state = GestionRepartidorState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await operacion();
      _state = GestionRepartidorState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = GestionRepartidorState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
