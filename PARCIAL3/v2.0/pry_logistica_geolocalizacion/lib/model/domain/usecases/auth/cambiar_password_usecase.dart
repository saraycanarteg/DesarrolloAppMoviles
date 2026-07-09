import '../../repositories/auth_repository.dart';

/// Caso de uso del repartidor (pantalla "Mi Perfil"): cambiar su propia
/// contraseña verificando primero la contraseña actual.
class CambiarPasswordUseCase {
  final AuthRepository repository;

  CambiarPasswordUseCase(this.repository);

  Future<void> call({
    required String passwordActual,
    required String passwordNueva,
  }) {
    return repository.cambiarPassword(
      passwordActual: passwordActual,
      passwordNueva: passwordNueva,
    );
  }
}
