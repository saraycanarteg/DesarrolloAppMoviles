class Mascota {
  final int?   id;
  final String nombre;
  final String especie;
  final String raza;
  final int    edad;
  final String descripcion;
  final String? imagenUrl;
  final bool   adoptada;

  Mascota({
    this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    required this.descripcion,
    this.imagenUrl,
    this.adoptada = false,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) => Mascota(
    id:          json['id'],
    nombre:      json['nombre'],
    especie:     json['especie'],
    raza:        json['raza'],
    edad:        json['edad'],
    descripcion: json['descripcion'],
    imagenUrl:   json['imagen_url'],
    adoptada:    json['adoptada'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'nombre':      nombre,
    'especie':     especie,
    'raza':        raza,
    'edad':        edad,
    'descripcion': descripcion,
    'imagen_url':  imagenUrl,
  };
}