import 'package:flutter/foundation.dart';
import '../model/domain/entities/sesion_usuario.dart';
import '../model/domain/usecases/auth/cambiar_password_usecase.dart';
import '../model/domain/usecases/auth/login_usecase.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final CambiarPasswordUseCase _cambiarPasswordUseCase;

  AuthViewModel(this._loginUseCase, this._cambiarPasswordUseCase);

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

  // ===== Cambio de contraseña (pantalla "Mi Perfil") =====

  bool _cambiandoPassword = false;
  bool get cambiandoPassword => _cambiandoPassword;

  /// Cambia la contraseña del usuario con sesión activa. Devuelve null si
  /// todo salió bien, o el mensaje de error para mostrar en el formulario.
  Future<String?> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    _cambiandoPassword = true;
    notifyListeners();

    try {
      await _cambiarPasswordUseCase(
        passwordActual: passwordActual,
        passwordNueva: passwordNueva,
      );
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _cambiandoPassword = false;
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
