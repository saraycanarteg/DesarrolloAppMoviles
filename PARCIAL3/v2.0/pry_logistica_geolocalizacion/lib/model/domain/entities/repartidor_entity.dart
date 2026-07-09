class RepartidorEntity {
  final String uid;
  final String nombre;
  final bool disponible;
  final String? vehiculo;
  final String? pedidoActualId;

  // Datos personales (el administrador los registra al dar de alta)
  final String? cedula;
  final String? telefono;
  final String? email;

  // Datos del vehículo
  final String? vehiculoTipo;
  final String? vehiculoMarca;
  final String? vehiculoPlaca;

  const RepartidorEntity({
    required this.uid,
    required this.nombre,
    required this.disponible,
    this.vehiculo,
    this.pedidoActualId,
    this.cedula,
    this.telefono,
    this.email,
    this.vehiculoTipo,
    this.vehiculoMarca,
    this.vehiculoPlaca,
  });

  RepartidorEntity copyWith({
    bool? disponible,
    String? pedidoActualId,
  }) {
    return RepartidorEntity(
      uid: this.uid,
      nombre: this.nombre,
      disponible: disponible ?? this.disponible,
      vehiculo: this.vehiculo,
      pedidoActualId: pedidoActualId ?? this.pedidoActualId,
      cedula: this.cedula,
      telefono: this.telefono,
      email: this.email,
      vehiculoTipo: this.vehiculoTipo,
      vehiculoMarca: this.vehiculoMarca,
      vehiculoPlaca: this.vehiculoPlaca,
    );
  }
}
