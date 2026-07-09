class RutaEntity {
  final String id;
  final String pedidoId;
  final String repartidorId;
  final String polylineCodificado;
  final double distanciaKm;
  final double duracionMin;

  const RutaEntity({
    required this.id,
    required this.pedidoId,
    required this.repartidorId,
    required this.polylineCodificado,
    required this.distanciaKm,
    required this.duracionMin,
  });
}
