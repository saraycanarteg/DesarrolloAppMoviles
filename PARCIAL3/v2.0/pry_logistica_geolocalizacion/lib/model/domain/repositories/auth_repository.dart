import '../entities/sesion_usuario.dart';

abstract class AuthRepository {
  Future<SesionUsuario> login(String email, String password);

  /// Alta de repartidor realizada por el administrador (no existe registro
  /// público). Lanza excepción si la cédula ya está registrada.
  Future<void> registrarRepartidor({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  });

  /// Cambia la contraseña del usuario autenticado, verificando primero
  /// la contraseña actual (reautenticación de Firebase).
  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  });

  Future<void> logout();
}
