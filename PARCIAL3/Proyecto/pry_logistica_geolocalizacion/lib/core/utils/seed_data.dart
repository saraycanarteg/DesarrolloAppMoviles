import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

Future<void> seedDatosIniciales() async {
  final auth = FirebaseAuth.instance;
  final db = FirebaseDatabase.instance.ref();

  try {
    // ============================================
    // 1. CREAR O LOGUEAR ADMIN
    // ============================================
    String uidAdmin;
    try {
      final credencialAdmin = await auth.createUserWithEmailAndPassword(
        email: 'dmayuquina@espe.edu.ec',
        password: 'admin123',
      );
      uidAdmin = credencialAdmin.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final cred = await auth.signInWithEmailAndPassword(
            email: 'dmayuquina@espe.edu.ec', password: 'admin123');
        uidAdmin = cred.user!.uid;
      } else {
        rethrow;
      }
    }

    await db.child('usuarios/$uidAdmin').update({
      'uid': uidAdmin,
      'nombre': 'Danny Ayuquina',
      'email': 'dmayuquina@espe.edu.ec',
      'rol': 'admin',
      'telefono': '+593987326319',
    });

    debugPrint('✅ Admin listo con UID: $uidAdmin');

    // ============================================
    // 2. CREAR O LOGUEAR REPARTIDOR
    // ============================================
    String uidRepartidor;
    try {
      final credencialRepartidor = await auth.createUserWithEmailAndPassword(
        email: 'andrescedeno1214@gmail.com',
        password: 'repartidor123',
      );
      uidRepartidor = credencialRepartidor.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final cred = await auth.signInWithEmailAndPassword(
            email: 'andrescedeno1214@gmail.com', password: 'repartidor123');
        uidRepartidor = cred.user!.uid;
      } else {
        rethrow;
      }
    }

    await db.child('usuarios/$uidRepartidor').update({
      'uid': uidRepartidor,
      'nombre': 'Andrés Cedeño',
      'email': 'andrescedeno1214@gmail.com',
      'rol': 'repartidor',
      'telefono': '+593912345678',
    });

    // Resetear al repartidor para que esté disponible y sin pedidos
    await db.child('repartidores/$uidRepartidor').update({
      'uid': uidRepartidor,
      'nombre': 'Andrés Cedeño',
      'disponible': true,
      'vehiculo': 'Moto ABC-123',
      'pedidoActualId': null,
    });

    debugPrint('✅ Repartidor reseteado y listo con UID: $uidRepartidor');

    // ============================================
    // 3. ACTUALIZAR PEDIDO DE PRUEBA (Mismo ID fijo)
    // ============================================
    // Iniciar sesión de nuevo como admin para crear/actualizar el pedido
    await auth.signInWithEmailAndPassword(
        email: 'dmayuquina@espe.edu.ec', password: 'admin123');

    // Usamos el ID de prueba fijo en lugar de push() para no llenar la base de datos
    final idPedido = '-Owtu0ksq2G-U-dUwKRs';
    final nuevaPedidoRef = db.child('pedidos/$idPedido');

    await nuevaPedidoRef.set({
      'id': idPedido,
      'clienteNombre': 'María López (Prueba Pendiente)',
      'direccionOrigen': 'Restaurante Central',
      'latOrigen': -0.180653,
      'lngOrigen': -78.467834,
      'direccionDestino': 'Calle Falsa 123',
      'latDestino': -0.185000,
      'lngDestino': -78.470000,
      'estado': 'pendiente',  // AHORA ESTÁ PENDIENTE
      'repartidorId': null,   // SIN ASIGNAR
      'creadoPor': uidAdmin,
      'creadoEn': ServerValue.timestamp,
      'asignadoEn': null,
      'enRutaEn': null,
      'entregadoEn': null,
    });

    debugPrint('✅ Pedido creado PENDIENTE con ID: $idPedido');

    // ============================================
    // 4. ACTUALIZAR RUTA (ID fijo referenciando el pedido real)
    // ============================================
    final idRuta = '-rutaPrueba123';
    final nuevaRutaRef = db.child('rutas/$idRuta');

    await nuevaRutaRef.set({
      'id': idRuta,
      'pedidoId': idPedido,
      'repartidorId': uidRepartidor,
      'polylineCodificado': 'a~l~Fj|yO_@_@e@A',
      'distanciaKm': 5.2,
      'duracionMin': 15.5,
    });

    debugPrint('✅ Ruta creada con ID: $idRuta');

    // ============================================
    // 5. CREAR UBICACIÓN INICIAL DEL REPARTIDOR
    // ============================================
    // Iniciamos sesión como el repartidor porque las reglas de seguridad
    // exigen que auth.uid coincida para poder escribir en "ubicaciones".
    await auth.signInWithEmailAndPassword(
        email: 'andrescedeno1214@gmail.com', password: 'repartidor123');

    await db.child('ubicaciones/$uidRepartidor').set({
      'repartidorId': uidRepartidor,
      'lat': -0.180653,
      'lng': -78.467834,
      'heading': 90.5,
      'speed': 12.3,
      'accuracy': 5.0,
      'timestamp': ServerValue.timestamp,
    });

    debugPrint('✅ Ubicación restablecida para repartidor: $uidRepartidor');
    debugPrint('🎉 ¡Base de datos re-sembrada con un pedido listo para asignar!');

    // Cierra sesión al terminar para evitar bugs de sesión cruzada
    await auth.signOut();
  } on FirebaseAuthException catch (e) {
    debugPrint('❌ Error de autenticación: ${e.code} - ${e.message}');
  } catch (e) {
    debugPrint('❌ Error general: $e');
  }
}
