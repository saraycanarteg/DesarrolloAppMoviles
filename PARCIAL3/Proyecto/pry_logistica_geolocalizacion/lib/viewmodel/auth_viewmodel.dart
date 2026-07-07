import 'package:flutter/foundation.dart';
import '../model/domain/entities/sesion_usuario.dart';
import '../model/domain/usecases/auth/login_usecase.dart';
import '../model/domain/usecases/auth/registrar_usecase.dart';
import '../model/domain/entities/usuario_entity.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegistrarUseCase _registrarUseCase;

  AuthViewModel(this._loginUseCase, this._registrarUseCase);

  AuthState _state = AuthState.idle;
  AuthState get state => _state;

  SesionUsuario? _sesion;
  SesionUsuario? get sesion => _sesion;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _sesion = await _loginUseCase(email, password);
      _state = AuthState.success;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  Future<void> registrar(String email, String password, String nombre, RolUsuario rol) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _sesion = await _registrarUseCase(email, password, nombre, rol);
      _state = AuthState.success;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _loginUseCase.repository.logout();
    _sesion = null;
    _state = AuthState.idle;
    notifyListeners();
  }
}
