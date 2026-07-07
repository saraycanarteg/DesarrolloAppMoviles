class RepartidorEntity {
  final String uid;
  final String nombre;
  final bool disponible;
  final String? vehiculo;
  final String? pedidoActualId;

  const RepartidorEntity({
    required this.uid,
    required this.nombre,
    required this.disponible,
    this.vehiculo,
    this.pedidoActualId,
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
    );
  }
}
