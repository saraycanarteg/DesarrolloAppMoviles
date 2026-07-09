import '../../domain/entities/direccion_entity.dart';

class DireccionModel extends DireccionEntity {
  const DireccionModel({
    required super.descripcion,
    required super.lat,
    required super.lng,
    super.codigoPais,
  });

  /// Parsea una respuesta de Nominatim (search o reverse).
  factory DireccionModel.fromNominatim(Map<String, dynamic> map) {
    final address = map['address'];
    return DireccionModel(
      descripcion: (map['display_name'] ?? '').toString(),
      lat: double.tryParse('${map['lat']}') ?? 0.0,
      lng: double.tryParse('${map['lon']}') ?? 0.0,
      codigoPais: address is Map ? address['country_code']?.toString() : null,
    );
  }
}
