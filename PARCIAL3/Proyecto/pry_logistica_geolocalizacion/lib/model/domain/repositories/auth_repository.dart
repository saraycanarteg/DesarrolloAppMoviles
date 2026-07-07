import '../entities/sesion_usuario.dart';
import '../entities/usuario_entity.dart';

abstract class AuthRepository {
  Future<SesionUsuario> login(String email, String password);
  Future<SesionUsuario> registrar(String email, String password, String nombre, RolUsuario rol);
  Future<void> logout();
}
