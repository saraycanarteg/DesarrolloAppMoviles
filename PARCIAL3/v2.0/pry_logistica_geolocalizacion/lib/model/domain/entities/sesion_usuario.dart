import 'usuario_entity.dart';
import 'repartidor_entity.dart';

class SesionUsuario {
  final UsuarioEntity usuario;
  final RepartidorEntity? repartidor;

  const SesionUsuario({
    required this.usuario,
    this.repartidor,
  });
}
