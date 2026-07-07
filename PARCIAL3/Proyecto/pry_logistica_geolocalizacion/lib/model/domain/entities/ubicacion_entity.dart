class UbicacionEntity {
  final String repartidorId;
  final double lat;
  final double lng;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final int timestamp;

  const UbicacionEntity({
    required this.repartidorId,
    required this.lat,
    required this.lng,
    this.heading,
    this.speed,
    this.accuracy,
    required this.timestamp,
  });
}
