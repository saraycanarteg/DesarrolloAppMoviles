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
      'cedula': '1712345675', // cédula de prueba válida (pasa el dígito verificador)
      'telefono': '+593912345678',
    });

    // Resetear al repartidor para que esté disponible y sin pedidos
    await db.child('repartidores/$uidRepartidor').update({
      'uid': uidRepartidor,
      'nombre': 'Andrés Cedeño',
      'disponible': true,
      'cedula': '1712345675',
      'telefono': '+593912345678',
      'email': 'andrescedeno1214@gmail.com',
      'vehiculo': 'Moto ABC-123',
      'vehiculoTipo': 'Moto',
      'vehiculoMarca': 'Yamaha FZ',
      'vehiculoPlaca': 'ABC-123',
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
      'direccionOrigen': 'Quicentro Shopping, Av. Naciones Unidas y 6 de Diciembre',
      'latOrigen': -0.176100,
      'lngOrigen': -78.478700,
      'direccionDestino': 'Plaza Foch, Reina Victoria y Mariscal Foch',
      'latDestino': -0.203200,
      'lngDestino': -78.490400,
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
    // 4. LIMPIAR RUTA CACHEADA DEL PEDIDO
    // ============================================
    // Las rutas se cachean en rutas/<pedidoId>; como el pedido usa un ID
    // fijo, hay que borrar la caché para que OSRM recalcule con las
    // coordenadas nuevas en vez de reutilizar la ruta vieja.
    try {
      await db.child('rutas/$idPedido').remove();
      // Entrada huérfana de versiones anteriores del seed
      await db.child('rutas/-rutaPrueba123').remove();
      debugPrint('✅ Ruta cacheada del pedido eliminada');
    } catch (e) {
      debugPrint('⚠️ No se pudo limpiar la ruta cacheada: $e');
    }

    // ============================================
    // 5. CREAR UBICACIÓN INICIAL DEL REPARTIDOR (solo si falta o está vieja)
    // ============================================
    // OJO: el seed corre en CADA arranque de la app en CUALQUIER dispositivo
    // (también el del administrador). Antes sobreescribía siempre la
    // ubicación del repartidor con este punto fijo, así que el mapa dejaba
    // de mostrar la posición GPS real del repartidor cada vez que alguien
    // abría la app. Ahora solo sembramos si no hay ubicación o si la última
    // señal tiene más de 10 minutos (repartidor claramente inactivo).
    const antiguedadMaximaMs = 10 * 60 * 1000;
    final ubicacionSnapshot = await db.child('ubicaciones/$uidRepartidor').get();
    final ubicacionActual = ubicacionSnapshot.value as Map<dynamic, dynamic>?;
    final timestampActual = (ubicacionActual?['timestamp'] as num?)?.toInt() ?? 0;
    final ubicacionVigente = DateTime.now().millisecondsSinceEpoch - timestampActual <
        antiguedadMaximaMs;

    if (ubicacionVigente) {
      debugPrint('✅ Ubicación real del repartidor vigente: no se sobreescribe');
    } else {
      // Iniciamos sesión como el repartidor porque las reglas de seguridad
      // exigen que auth.uid coincida para poder escribir en "ubicaciones".
      await auth.signInWithEmailAndPassword(
          email: 'andrescedeno1214@gmail.com', password: 'repartidor123');

      // Punto sobre la Av. 6 de Diciembre, unas cuadras al norte del origen,
      // para que la ruta OSRM se trace por calles reales.
      await db.child('ubicaciones/$uidRepartidor').set({
        'repartidorId': uidRepartidor,
        'lat': -0.171500,
        'lng': -78.478000,
        'heading': 90.5,
        'speed': 12.3,
        'accuracy': 5.0,
        'timestamp': ServerValue.timestamp,
      });

      debugPrint('✅ Ubicación restablecida para repartidor: $uidRepartidor');
    }
    debugPrint('🎉 ¡Base de datos re-sembrada con un pedido listo para asignar!');

    // Cierra sesión al terminar para evitar bugs de sesión cruzada
    await auth.signOut();
  } on FirebaseAuthException catch (e) {
    debugPrint('❌ Error de autenticación: ${e.code} - ${e.message}');
  } catch (e) {
    debugPrint('❌ Error general: $e');
  }
}
