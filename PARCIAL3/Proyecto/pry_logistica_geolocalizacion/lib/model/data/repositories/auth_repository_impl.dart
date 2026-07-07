import '../../domain/entities/sesion_usuario.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<SesionUsuario> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<SesionUsuario> registrar(String email, String password, String nombre, RolUsuario rol) {
    return remoteDataSource.registrar(email, password, nombre, rol);
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}
