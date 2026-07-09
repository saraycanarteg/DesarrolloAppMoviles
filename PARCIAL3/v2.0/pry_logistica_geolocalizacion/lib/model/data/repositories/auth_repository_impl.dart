import '../../domain/entities/sesion_usuario.dart';
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
  Future<void> registrarRepartidor({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  }) {
    return remoteDataSource.registrarRepartidor(
      nombre: nombre,
      cedula: cedula,
      telefono: telefono,
      email: email,
      password: password,
      vehiculoTipo: vehiculoTipo,
      vehiculoMarca: vehiculoMarca,
      vehiculoPlaca: vehiculoPlaca,
    );
  }

  @override
  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) {
    return remoteDataSource.cambiarPassword(
      passwordActual: passwordActual,
      passwordNueva: passwordNueva,
    );
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}
