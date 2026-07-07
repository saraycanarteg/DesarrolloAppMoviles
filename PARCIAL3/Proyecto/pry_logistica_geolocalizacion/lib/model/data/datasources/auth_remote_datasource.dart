import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/constants/firebase_constants.dart';
import '../models/usuario_model.dart';
import '../models/repartidor_model.dart';
import '../../domain/entities/sesion_usuario.dart';
import '../../domain/entities/usuario_entity.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

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

      // Actualizar fcmToken (placeholder)
      await _database
          .ref()
          .child(FirebaseConstants.usuariosNode)
          .child(uid)
          .update({'fcmToken': 'pending_fcm_integration'});

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

  Future<SesionUsuario> registrar(String email, String password, String nombre, RolUsuario rol) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      final usuarioModel = UsuarioModel(
        uid: uid,
        nombre: nombre,
        email: email,
        rol: rol,
        telefono: null,
        fcmToken: null,
        creadoEn: DateTime.now().millisecondsSinceEpoch,
      );

      final usuarioMap = {
        'uid': uid,
        'nombre': nombre,
        'email': email,
        'rol': UsuarioEntity.rolToString(rol),
        'telefono': null,
        'fcmToken': null,
        'creadoEn': usuarioModel.creadoEn,
      };

      await _database.ref().child(FirebaseConstants.usuariosNode).child(uid).set(usuarioMap);

      RepartidorModel? repartidorModel;

      if (rol == RolUsuario.repartidor) {
        repartidorModel = RepartidorModel(
          uid: uid,
          nombre: nombre,
          disponible: true,
          vehiculo: null,
          pedidoActualId: null,
        );

        final repartidorMap = {
          'uid': uid,
          'nombre': nombre,
          'disponible': true,
          'vehiculo': null,
          'pedidoActualId': null,
        };

        await _database.ref().child(FirebaseConstants.repartidoresNode).child(uid).set(repartidorMap);
      }

      return SesionUsuario(
        usuario: usuarioModel,
        repartidor: repartidorModel,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      final msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        throw Exception(msg.substring(11));
      }
      throw Exception(msg);
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
