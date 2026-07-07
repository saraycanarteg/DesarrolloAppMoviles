enum RolUsuario { admin, repartidor }

class UsuarioEntity {
  final String uid;
  final String nombre;
  final String email;
  final RolUsuario rol;
  final String? telefono;
  final String? fcmToken;
  final int creadoEn;

  const UsuarioEntity({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
    this.fcmToken,
    required this.creadoEn,
  });

  static RolUsuario stringToRol(String rolStr) {
    if (rolStr == 'admin') return RolUsuario.admin;
    if (rolStr == 'repartidor') return RolUsuario.repartidor;
    throw ArgumentError('RolUsuario no válido: $rolStr');
  }

  static String rolToString(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.admin:
        return 'admin';
      case RolUsuario.repartidor:
        return 'repartidor';
    }
  }
}
