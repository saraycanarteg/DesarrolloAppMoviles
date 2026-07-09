import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/constants/firebase_constants.dart';
import '../models/usuario_model.dart';
import '../models/repartidor_model.dart';
import '../../domain/entities/sesion_usuario.dart';
import '../../domain/entities/usuario_entity.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Obtiene el token FCM del dispositivo (lo inyecta el servicio de
  /// notificaciones desde main.dart; es null en plataformas sin soporte).
  final Future<String?> Function()? _obtenerFcmToken;

  AuthRemoteDataSource({this._obtenerFcmToken});

  Future<SesionUsuario> login(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      // Leer usuario
      final DataSnapshot userSnapshot = await _database
          .ref()
          .child(FirebaseConstants.usuariosNode)
          .child(uid)
          .get();

      if (!userSnapshot.exists || userSnapshot.value == null) {
        await _firebaseAuth.signOut();
        throw Exception('Perfil de usuario no encontrado en la base de datos.');
      }

      final Map<dynamic, dynamic> userMap = userSnapshot.value as Map<dynamic, dynamic>;
      final UsuarioModel usuario = UsuarioModel.fromMap(userMap, uid);

      // Registrar el token FCM del dispositivo para poder enviarle
      // notificaciones push (nuevo pedido, entrega confirmada).
      final String? fcmToken = await _obtenerFcmToken?.call();
      if (fcmToken != null) {
        await _database
            .ref()
            .child(FirebaseConstants.usuariosNode)
            .child(uid)
            .update({'fcmToken': fcmToken});
      }

      RepartidorModel? repartidor;

      if (usuario.rol == RolUsuario.repartidor) {
        final DataSnapshot repSnapshot = await _database
            .ref()
            .child(FirebaseConstants.repartidoresNode)
            .child(uid)
            .get();

        if (!repSnapshot.exists || repSnapshot.value == null) {
          await _firebaseAuth.signOut();
          throw Exception('Datos de repartidor no encontrados o inconsistentes.');
        }

        // Marcar como disponible al iniciar sesión
        await _database.ref().child(FirebaseConstants.repartidoresNode).child(uid).update({'disponible': true});

        final Map<dynamic, dynamic> repMap = Map<dynamic, dynamic>.from(repSnapshot.value as Map<dynamic, dynamic>);
        repMap['disponible'] = true; // Actualizamos el valor localmente
        repartidor = RepartidorModel.fromMap(repMap, uid);
      }

      return SesionUsuario(
        usuario: usuario,
        repartidor: repartidor,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      // Remover prefijo "Exception: " si está presente
      final msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        throw Exception(msg.substring(11));
      }
      throw Exception(msg);
    }
  }

  /// Alta de un repartidor hecha por el ADMINISTRADOR (no hay registro
  /// público). Verifica que la cédula no exista, crea la cuenta de Firebase
  /// Auth en una app secundaria (para no cerrar la sesión del admin) y graba
  /// el perfil en `usuarios` y `repartidores`.
  Future<void> registrarRepartidor({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
    required String vehiculoTipo,
    required String vehiculoMarca,
    required String vehiculoPlaca,
  }) async {
    // 1. Verificar duplicados por cédula. Leemos todo el nodo y filtramos
    // localmente para no exigir ".indexOn" en las reglas de Firebase
    // (mismo criterio que asignarRepartidor en DatabaseRemoteDataSource).
    final snapshot = await _database.ref().child(FirebaseConstants.repartidoresNode).get();
    final data = snapshot.value;
    if (data is Map) {
      for (final entrada in data.values) {
        if (entrada is Map && entrada['cedula']?.toString() == cedula) {
          throw Exception('Ya existe un repartidor registrado con la cédula $cedula');
        }
      }
    }

    // 2. Crear la cuenta en una app secundaria de Firebase: si usáramos la
    // instancia principal, createUserWithEmailAndPassword iniciaría sesión
    // como el repartidor nuevo y expulsaría al administrador.
    FirebaseApp appSecundaria;
    try {
      appSecundaria = Firebase.app('registro_repartidor');
    } on FirebaseException {
      appSecundaria = await Firebase.initializeApp(
        name: 'registro_repartidor',
        options: Firebase.app().options,
      );
    }

    final authSecundaria = FirebaseAuth.instanceFor(app: appSecundaria);

    try {
      final credencial = await authSecundaria.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String uid = credencial.user!.uid;

      // 3. Grabar el perfil usando la sesión secundaria (auth.uid == uid nuevo),
      // igual que hace el seed, para cumplir las reglas de seguridad.
      final dbSecundaria = FirebaseDatabase.instanceFor(app: appSecundaria);

      await dbSecundaria.ref().child(FirebaseConstants.usuariosNode).child(uid).set({
        'uid': uid,
        'nombre': nombre,
        'email': email,
        'rol': UsuarioEntity.rolToString(RolUsuario.repartidor),
        'cedula': cedula,
        'telefono': telefono,
        'fcmToken': null,
        'creadoEn': ServerValue.timestamp,
      });

      await dbSecundaria.ref().child(FirebaseConstants.repartidoresNode).child(uid).set({
        'uid': uid,
        'nombre': nombre,
        'cedula': cedula,
        'telefono': telefono,
        'email': email,
        // Queda no disponible hasta que inicie sesión en su dispositivo
        'disponible': false,
        'vehiculo': '$vehiculoTipo $vehiculoPlaca',
        'vehiculoTipo': vehiculoTipo,
        'vehiculoMarca': vehiculoMarca,
        'vehiculoPlaca': vehiculoPlaca,
        'pedidoActualId': null,
      });

      await authSecundaria.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } finally {
      // Liberar la app secundaria; si falla, no afecta la sesión principal.
      try {
        await appSecundaria.delete();
      } catch (_) {}
    }
  }

  /// Cambio de contraseña del usuario con sesión activa (pantalla "Mi
  /// Perfil" del repartidor). Firebase exige reautenticarse con la
  /// contraseña actual antes de permitir el cambio.
  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No hay una sesión activa');
    }

    try {
      final credencial = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordActual,
      );
      await user.reauthenticateWithCredential(credencial);
      await user.updatePassword(passwordNueva);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('La contraseña actual es incorrecta');
        case 'weak-password':
          throw Exception('La contraseña nueva es demasiado débil');
        case 'too-many-requests':
          throw Exception('Demasiados intentos, intenta más tarde');
        case 'network-request-failed':
          throw Exception('Sin conexión a internet');
        default:
          throw Exception('No se pudo cambiar la contraseña: ${e.message}');
      }
    }
  }

  Future<void> logout() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Intentar marcar como no disponible antes de cerrar sesión si es un repartidor
      try {
        final repSnapshot = await _database.ref().child(FirebaseConstants.repartidoresNode).child(user.uid).get();
        if (repSnapshot.exists) {
          await _database.ref().child(FirebaseConstants.repartidoresNode).child(user.uid).update({'disponible': false});
        }
      } catch (_) {
        // Ignorar si hay error o no tiene permisos (ej. token expirado o no es repartidor)
      }
    }
    await _firebaseAuth.signOut();
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Correo o contraseña incorrectos');
      case 'invalid-email':
        return Exception('Correo inválido');
      case 'too-many-requests':
        return Exception('Demasiados intentos, intenta más tarde');
      case 'network-request-failed':
        return Exception('Sin conexión a internet');
      case 'email-already-in-use':
        return Exception('Este correo ya está registrado');
      case 'weak-password':
        return Exception('La contraseña es demasiado débil');
      default:
        return Exception('Error de autenticación: ${e.message}');
    }
  }
}
