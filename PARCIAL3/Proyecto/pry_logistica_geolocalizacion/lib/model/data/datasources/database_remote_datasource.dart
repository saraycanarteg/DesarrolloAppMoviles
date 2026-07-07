import 'package:firebase_database/firebase_database.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../domain/entities/pedido_entity.dart';
import '../models/pedido_model.dart';
import '../models/ruta_model.dart';
import '../models/ubicacion_model.dart';

class DatabaseRemoteDataSource {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<PedidoModel> crearPedido(PedidoModel pedido) async {
    final nuevaRef = _database.ref().child(FirebaseConstants.pedidosNode).push();
    final String idGenerado = nuevaRef.key!;
    
    final pedidoConId = PedidoModel(
      id: idGenerado,
      clienteNombre: pedido.clienteNombre,
      direccionOrigen: pedido.direccionOrigen,
      latOrigen: pedido.latOrigen,
      lngOrigen: pedido.lngOrigen,
      direccionDestino: pedido.direccionDestino,
      latDestino: pedido.latDestino,
      lngDestino: pedido.lngDestino,
      estado: pedido.estado,
      repartidorId: pedido.repartidorId,
      creadoPor: pedido.creadoPor,
      creadoEn: pedido.creadoEn,
      asignadoEn: pedido.asignadoEn,
      enRutaEn: pedido.enRutaEn,
      entregadoEn: pedido.entregadoEn,
    );

    await nuevaRef.set(pedidoConId.toMap());
    return pedidoConId;
  }

  Future<RutaModel> crearRuta(RutaModel ruta) async {
    final nuevaRef = _database.ref().child(FirebaseConstants.rutasNode).push();
    final String idGenerado = nuevaRef.key!;

    final rutaConId = RutaModel(
      id: idGenerado,
      pedidoId: ruta.pedidoId,
      repartidorId: ruta.repartidorId,
      polylineCodificado: ruta.polylineCodificado,
      distanciaKm: ruta.distanciaKm,
      duracionMin: ruta.duracionMin,
    );

    await nuevaRef.set(rutaConId.toMap());
    return rutaConId;
  }

  Future<void> actualizarUbicacion(String repartidorId, UbicacionModel ubicacion) async {
    await _database
        .ref()
        .child(FirebaseConstants.ubicacionesNode)
        .child(repartidorId)
        .set(ubicacion.toMap());
  }

  Future<void> asignarRepartidor(String pedidoId, {String? repartidorManualId, List<String> excluidos = const []}) async {
    final pedidoSnapshot = await _database.ref().child(FirebaseConstants.pedidosNode).child(pedidoId).get();
    if (!pedidoSnapshot.exists) throw Exception('Pedido no encontrado');
    
    final pedidoMap = pedidoSnapshot.value as Map<dynamic, dynamic>;
    final latOrigen = (pedidoMap['latOrigen'] ?? 0.0).toDouble();
    final lngOrigen = (pedidoMap['lngOrigen'] ?? 0.0).toDouble();

    String? candidatoId = repartidorManualId;

    if (candidatoId == null) {
      // Asignación Automática: Buscar disponibles
      // Nota: Hacemos un get() general y filtramos localmente para evitar 
      // depender de ".indexOn": "disponible" en las reglas de Firebase Database.
      final repartidoresSnapshot = await _database.ref().child(FirebaseConstants.repartidoresNode).get();
      if (!repartidoresSnapshot.exists) throw Exception('No hay repartidores disponibles');

      final allRepartidores = repartidoresSnapshot.value;
      final repartidoresMap = <dynamic, dynamic>{};

      if (allRepartidores is Map) {
        allRepartidores.forEach((key, value) {
          if (value is Map && value['disponible'] == true) {
            repartidoresMap[key] = value;
          }
        });

        // Fallback ultra-seguro para pruebas: Si no hay nadie "disponible", agarramos a CUALQUIERA
        if (repartidoresMap.isEmpty) {
          allRepartidores.forEach((key, value) {
            if (value is Map) {
              repartidoresMap[key] = value;
            }
          });
        }
      }

      if (repartidoresMap.isEmpty) throw Exception('DEBUG: repartidoresMap vacio.');
      
      // Obtener ubicaciones para calcular cercanía
      final ubicacionesSnapshot = await _database.ref().child(FirebaseConstants.ubicacionesNode).get();
      final ubicacionesMap = (ubicacionesSnapshot.value as Map<dynamic, dynamic>?) ?? {};

      double minDistancia = double.infinity;

      repartidoresMap.forEach((key, value) {
        final rId = key.toString();
        if (excluidos.contains(rId)) return; // No proponer de nuevo al mismo

        final ubi = ubicacionesMap[rId];
        if (ubi != null) {
          final rLat = (ubi['lat'] ?? 0.0).toDouble();
          final rLng = (ubi['lng'] ?? 0.0).toDouble();
          
          final dist = GeoUtils.calcularDistanciaHaversine(latOrigen, lngOrigen, rLat, rLng);
          if (dist < minDistancia) {
            minDistancia = dist;
            candidatoId = rId;
          }
        }
      });

      // Fallback: Si nadie tenía ubicación registrada, asignar al primero disponible
      if (candidatoId == null) {
        for (var key in repartidoresMap.keys) {
          final rId = key.toString();
          if (!excluidos.contains(rId)) {
            candidatoId = rId;
            break;
          }
        }
      }

      if (candidatoId == null) throw Exception('DEBUG: candidatoId nulo. MapSize=${repartidoresMap.length}, Excluidos=${excluidos.length}');
    }

    // Reemplazamos runTransaction por update para evitar el bug conocido de Firebase
    // donde las transacciones fallan al evaluar reglas que usan "root.child()".
    try {
      final repartidorRef = _database.ref().child(FirebaseConstants.repartidoresNode).child(candidatoId!);
      await repartidorRef.update({
        'disponible': false,
        'pedidoActualId': pedidoId,
      });

      // Si pasamos el update sin lanzar excepción de Permission Denied, la asignación es un éxito.
      await _database.ref().child(FirebaseConstants.pedidosNode).child(pedidoId).update({
        'estado': 'esperando_confirmacion',
        'repartidorId': candidatoId,
        'asignadoEn': ServerValue.timestamp,
      });
    } catch (e) {
      if (repartidorManualId == null) {
        throw Exception('DEBUG: Update fallido en repartidor. Firebase arrojó: $e');
      } else {
        throw Exception('El repartidor manual ya no está disponible o no hay permisos');
      }
    }
  }

  Future<void> aceptarPedido(String repartidorId, String pedidoId) async {
    try {
      await _database.ref().child(FirebaseConstants.pedidosNode).child(pedidoId).update({
        'estado': 'asignado',
      });
    } catch (e) {
      throw Exception('DEBUG Error en aceptarPedido: $e');
    }
  }

  Future<void> rechazarPedido(String repartidorId, String pedidoId, {bool reintentarAutomatico = false, List<String>? excluidos}) async {
    // Transacción inversa
    try {
      final repartidorRef = _database.ref().child(FirebaseConstants.repartidoresNode).child(repartidorId);
      await repartidorRef.update({'disponible': true});
      await repartidorRef.child('pedidoActualId').remove();

      final pedidoRef = _database.ref().child(FirebaseConstants.pedidosNode).child(pedidoId);
      await pedidoRef.update({'estado': 'pendiente'});
      await pedidoRef.child('repartidorId').remove();
    } catch (e) {
      throw Exception('DEBUG Error en rechazarPedido: $e');
    }

    if (reintentarAutomatico) {
      final nuevosExcluidos = excluidos != null ? List<String>.from(excluidos) : <String>[];
      nuevosExcluidos.add(repartidorId);
      
      try {
        await asignarRepartidor(pedidoId, excluidos: nuevosExcluidos);
      } catch (e) {
        // Ignorar si no hay más disponibles
      }
    }
  }

  Stream<PedidoModel?> observarPedidoPropuesto(String repartidorId) {
    return _database.ref().child(FirebaseConstants.pedidosNode).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return null;

      PedidoModel? pedidoEncontrado;
      data.forEach((key, value) {
        final mapValue = Map<dynamic, dynamic>.from(value as Map);
        if (mapValue['repartidorId'] == repartidorId) {
          final p = PedidoModel.fromMap(mapValue);
          // Solo consideramos como actual/propuesto si no está entregado ni pendiente (ya que pendiente no tiene repartidorId, pero por si acaso)
          if (p.estado == EstadoPedido.esperandoConfirmacion || 
              p.estado == EstadoPedido.asignado || 
              p.estado == EstadoPedido.enRuta) {
            pedidoEncontrado = p;
          }
        }
      });
      
      return pedidoEncontrado;
    });
  }

  Stream<List<PedidoModel>> observarTodosLosPedidos() {
    return _database.ref().child(FirebaseConstants.pedidosNode).onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      // Obtener info de repartidores de una vez
      final repsSnapshot = await _database.ref().child(FirebaseConstants.repartidoresNode).get();
      final repsMap = (repsSnapshot.value as Map<dynamic, dynamic>?) ?? {};

      final list = <PedidoModel>[];
      data.forEach((key, value) {
        var mapValue = Map<dynamic, dynamic>.from(value as Map<dynamic, dynamic>);
        final rId = mapValue['repartidorId'];
        if (rId != null && repsMap.containsKey(rId)) {
           mapValue['repartidorNombre'] = repsMap[rId]['nombre'];
           mapValue['repartidorVehiculo'] = repsMap[rId]['vehiculo'];
        }
        list.add(PedidoModel.fromMap(mapValue));
      });
      
      // Ordenar descendente por fecha de creación (los más recientes primero)
      list.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
      
      return list;
    });
  }
}
