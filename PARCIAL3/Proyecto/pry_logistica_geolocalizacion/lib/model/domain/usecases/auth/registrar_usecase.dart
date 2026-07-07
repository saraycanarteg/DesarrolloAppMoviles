import '../../entities/sesion_usuario.dart';
import '../../entities/usuario_entity.dart';
import '../../repositories/auth_repository.dart';

class RegistrarUseCase {
  final AuthRepository repository;

  RegistrarUseCase(this.repository);

  Future<SesionUsuario> call(String email, String password, String nombre, RolUsuario rol) {
    return repository.registrar(email, password, nombre, rol);
  }
}
