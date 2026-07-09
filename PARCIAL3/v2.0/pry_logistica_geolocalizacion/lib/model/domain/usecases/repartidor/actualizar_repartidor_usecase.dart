import '../../repositories/pedido_repository.dart';

/// Caso de uso del administrador: editar el teléfono, correo y vehículo
/// de un repartidor ya registrado (nombre y cédula no se modifican).
class ActualizarRepartidorUseCase {
  final PedidoRepository repository;

  ActualizarRepartidorUseCase(this.repository);

  Future<void> call(
    String uid, {
    required String telefono,
    required String email,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  }) {
    return repository.actualizarRepartidor(
      uid,
      telefono: telefono,
      email: email,
      vehiculoTipo: vehiculoTipo,
      vehiculoMarca: vehiculoMarca,
      vehiculoPlaca: vehiculoPlaca,
    );
  }
}
