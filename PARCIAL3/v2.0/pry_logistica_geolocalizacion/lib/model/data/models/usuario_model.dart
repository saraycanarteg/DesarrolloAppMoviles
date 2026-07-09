import '../../domain/entities/usuario_entity.dart';

class UsuarioModel extends UsuarioEntity {
  const UsuarioModel({
    required super.uid,
    required super.nombre,
    required super.email,
    required super.rol,
    super.telefono,
    super.fcmToken,
    required super.creadoEn,
  });

  factory UsuarioModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    return UsuarioModel(
      uid: uid,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      rol: UsuarioEntity.stringToRol(map['rol'] ?? 'repartidor'),
      telefono: map['telefono'],
      fcmToken: map['fcmToken'],
      creadoEn: map['creadoEn'] ?? 0,
    );
  }
}
