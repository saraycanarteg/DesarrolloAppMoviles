import '../../repositories/auth_repository.dart';

/// Caso de uso del administrador: dar de alta un repartidor con sus datos
/// personales (cédula única) y los de su vehículo.
class RegistrarRepartidorUseCase {
  final AuthRepository repository;

  RegistrarRepartidorUseCase(this.repository);

  Future<void> call({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  }) {
    return repository.registrarRepartidor(
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
}
