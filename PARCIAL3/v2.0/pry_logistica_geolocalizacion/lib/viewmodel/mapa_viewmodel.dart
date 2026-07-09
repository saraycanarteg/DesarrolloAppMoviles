import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/utils/geo_utils.dart';
import '../model/domain/entities/pedido_entity.dart';
import '../model/domain/entities/ruta_entity.dart';
import '../model/domain/entities/ubicacion_entity.dart';
import '../model/domain/usecases/tracking/calcular_ruta_directa_usecase.dart';
import '../model/domain/usecases/tracking/obtener_ruta_usecase.dart';
import '../model/domain/usecases/tracking/observar_ubicacion_repartidor_usecase.dart';
import '../model/domain/usecases/pedido/iniciar_ruta_usecase.dart';
import '../model/domain/usecases/pedido/iniciar_ruta_cliente_usecase.dart';
import '../model/domain/usecases/pedido/marcar_recogido_usecase.dart';
import '../model/domain/usecases/pedido/marcar_entregado_usecase.dart';
import '../model/domain/usecases/pedido/observar_todos_los_pedidos_usecase.dart';

enum MapaState { inicial, cargandoRuta, listo, error }

/// Alimenta la pantalla del mapa durante todo el ciclo de la entrega:
/// - Ruta base tienda→cliente (OSRM, cacheada en RTDB).
/// - Tramo dinámico posición del repartidor→objetivo actual (tienda o
///   cliente según el estado), recalculado cuando el repartidor se mueve.
/// - Pedido observado en vivo para reaccionar a los cambios de estado.
/// - Transiciones: ir a tienda → recogido (máx. [radioRecogidaKm] km de la
///   tienda) → en ruta a cliente → entregado.
class MapaViewModel extends ChangeNotifier {
  /// Rango máximo (km) al que el repartidor puede confirmar la recogida.
  static const double radioRecogidaKm = 5.0;

  /// Movimiento mínimo (km) del repartidor antes de recalcular el tramo
  /// dinámico contra OSRM (para no saturar el servicio público).
  static const double _umbralRecalculoKm = 0.15;

  final ObtenerRutaUseCase _obtenerRutaUseCase;
  final CalcularRutaDirectaUseCase _calcularRutaDirectaUseCase;
  final ObservarUbicacionRepartidorUseCase _observarUbicacionUseCase;
  final ObservarTodosLosPedidosUseCase _observarTodosLosPedidosUseCase;
  final IniciarRutaUseCase _iniciarRutaUseCase;
  final MarcarRecogidoUseCase _marcarRecogidoUseCase;
  final IniciarRutaClienteUseCase _iniciarRutaClienteUseCase;
  final MarcarEntregadoUseCase _marcarEntregadoUseCase;

  MapaViewModel(
    this._obtenerRutaUseCase,
    this._calcularRutaDirectaUseCase,
    this._observarUbicacionUseCase,
    this._observarTodosLosPedidosUseCase,
    this._iniciarRutaUseCase,
    this._marcarRecogidoUseCase,
    this._iniciarRutaClienteUseCase,
    this._marcarEntregadoUseCase,
  );

  StreamSubscription<UbicacionEntity?>? _ubicacionSubscription;
  StreamSubscription<List<PedidoEntity>>? _pedidoSubscription;

  MapaState _state = MapaState.inicial;
  MapaState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PedidoEntity? _pedido;
  PedidoEntity? get pedido => _pedido;

  /// Ruta base tienda→cliente (estática, cacheada por pedido).
  RutaEntity? _rutaBase;
  RutaEntity? get rutaBase => _rutaBase;

  List<List<double>> _puntosRutaBase = [];
  List<List<double>> get puntosRutaBase => _puntosRutaBase;

  /// Tramo dinámico: posición actual del repartidor → objetivo del estado
  /// (tienda antes de recoger, cliente después).
  RutaEntity? _rutaDinamica;
  RutaEntity? get rutaDinamica => _rutaDinamica;

  List<List<double>> _puntosRutaDinamica = [];
  List<List<double>> get puntosRutaDinamica => _puntosRutaDinamica;

  UbicacionEntity? _ubicacionRepartidor;
  UbicacionEntity? get ubicacionRepartidor => _ubicacionRepartidor;

  bool _procesandoAccion = false;
  bool get procesandoAccion => _procesandoAccion;

  bool _calculandoDinamica = false;
  double? _latUltimoCalculo;
  double? _lngUltimoCalculo;

  /// El objetivo del tramo dinámico según el estado: la tienda mientras no
  /// se haya recogido el pedido, el cliente después. Null si el pedido no
  /// está en un estado con desplazamiento.
  ({double lat, double lng})? get _objetivoDinamico {
    final p = _pedido;
    if (p == null) return null;
    switch (p.estado) {
      case EstadoPedido.asignado:
      case EstadoPedido.enRutaATienda:
        return (lat: p.latOrigen, lng: p.lngOrigen);
      case EstadoPedido.recogido:
      case EstadoPedido.enRutaACliente:
        return (lat: p.latDestino, lng: p.lngDestino);
      default:
        return null;
    }
  }

  bool get _rumboATienda =>
      _pedido?.estado == EstadoPedido.asignado ||
      _pedido?.estado == EstadoPedido.enRutaATienda;

  /// Distancia en línea recta del repartidor a la tienda (para el rango de recogida).
  double? get distanciaLinealATiendaKm {
    final p = _pedido;
    final u = _ubicacionRepartidor;
    if (p == null || u == null) return null;
    return GeoUtils.calcularDistanciaHaversine(u.lat, u.lng, p.latOrigen, p.lngOrigen);
  }

  bool get dentroDeRangoRecogida =>
      (distanciaLinealATiendaKm ?? double.infinity) <= radioRecogidaKm;

  /// Distancia del recorrido completo que le falta al pedido:
  /// - Rumbo a la tienda: repartidor→tienda + tienda→cliente.
  /// - Después de recoger: repartidor→cliente.
  double? get distanciaTotalKm {
    if (_rumboATienda) {
      if (_rutaDinamica != null && _rutaBase != null) {
        return _rutaDinamica!.distanciaKm + _rutaBase!.distanciaKm;
      }
      return _rutaBase?.distanciaKm;
    }
    return _rutaDinamica?.distanciaKm ?? _rutaBase?.distanciaKm;
  }

  double? get duracionTotalMin {
    if (_rumboATienda) {
      if (_rutaDinamica != null && _rutaBase != null) {
        return _rutaDinamica!.duracionMin + _rutaBase!.duracionMin;
      }
      return _rutaBase?.duracionMin;
    }
    return _rutaDinamica?.duracionMin ?? _rutaBase?.duracionMin;
  }

  /// Tramo actual (repartidor→tienda o repartidor→cliente) para el desglose.
  double? get distanciaTramoKm => _rutaDinamica?.distanciaKm;
  double? get duracionTramoMin => _rutaDinamica?.duracionMin;

  Future<void> cargar(PedidoEntity pedido) async {
    _pedido = pedido;
    _rutaBase = null;
    _puntosRutaBase = [];
    _rutaDinamica = null;
    _puntosRutaDinamica = [];
    _ubicacionRepartidor = null;
    _latUltimoCalculo = null;
    _lngUltimoCalculo = null;
    _errorMessage = null;
    _state = MapaState.cargandoRuta;
    notifyListeners();

    // Mantener el pedido sincronizado con la RTDB para que el mapa
    // reaccione a los cambios de estado (propios o del otro rol).
    await _pedidoSubscription?.cancel();
    _pedidoSubscription = _observarTodosLosPedidosUseCase().listen((pedidos) {
      final actualizado = pedidos.where((p) => p.id == pedido.id);
      if (actualizado.isEmpty) return;
      final nuevo = actualizado.first;
      final cambioEstado = nuevo.estado != _pedido?.estado;
      _pedido = nuevo;
      if (cambioEstado) {
        // El objetivo del tramo dinámico pudo cambiar (tienda → cliente)
        _recalcularRutaDinamica(forzar: true);
      }
      notifyListeners();
    });

    // Seguir en vivo al repartidor asignado (si hay uno)
    await _ubicacionSubscription?.cancel();
    final repartidorId = pedido.repartidorId;
    if (repartidorId != null && repartidorId.isNotEmpty) {
      _ubicacionSubscription = _observarUbicacionUseCase(repartidorId).listen((ubicacion) {
        _ubicacionRepartidor = ubicacion;
        _recalcularRutaDinamica();
        notifyListeners();
      });
    }

    try {
      _rutaBase = await _obtenerRutaUseCase(pedido);
      _puntosRutaBase = GeoUtils.decodificarPolyline(_rutaBase!.polylineCodificado);
      _state = MapaState.listo;
    } catch (e) {
      _state = MapaState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  /// Recalcula el tramo repartidor→objetivo cuando hay posición nueva.
  /// Se limita a movimientos mayores a [_umbralRecalculoKm] para no abusar
  /// del servicio público de OSRM.
  Future<void> _recalcularRutaDinamica({bool forzar = false}) async {
    final ubicacion = _ubicacionRepartidor;
    final objetivo = _objetivoDinamico;

    if (objetivo == null) {
      // Estado sin desplazamiento (pendiente, entregado…): limpiar el tramo
      if (_rutaDinamica != null) {
        _rutaDinamica = null;
        _puntosRutaDinamica = [];
        notifyListeners();
      }
      return;
    }
    if (ubicacion == null || _calculandoDinamica) return;

    if (!forzar && _latUltimoCalculo != null) {
      final movimiento = GeoUtils.calcularDistanciaHaversine(
          _latUltimoCalculo!, _lngUltimoCalculo!, ubicacion.lat, ubicacion.lng);
      if (movimiento < _umbralRecalculoKm) return;
    }

    _calculandoDinamica = true;
    try {
      final ruta = await _calcularRutaDirectaUseCase(
        latOrigen: ubicacion.lat,
        lngOrigen: ubicacion.lng,
        latDestino: objetivo.lat,
        lngDestino: objetivo.lng,
      );
      _rutaDinamica = ruta;
      _puntosRutaDinamica = GeoUtils.decodificarPolyline(ruta.polylineCodificado);
      _latUltimoCalculo = ubicacion.lat;
      _lngUltimoCalculo = ubicacion.lng;
      notifyListeners();
    } catch (_) {
      // Sin ruta dinámica seguimos mostrando la ruta base; se reintentará
      // con la siguiente posición GPS.
    } finally {
      _calculandoDinamica = false;
    }
  }

  // ===== Transiciones de estado del repartidor =====
  // Devuelven null si todo salió bien, o el mensaje de error a mostrar.

  /// asignado → en_ruta_a_tienda
  Future<String?> irATienda() {
    return _ejecutarAccion(() async {
      await _iniciarRutaUseCase(_pedido!.id);
      _pedido = _pedido!.copyWith(estado: EstadoPedido.enRutaATienda);
    });
  }

  /// en_ruta_a_tienda → recogido. Solo se permite dentro del rango lógico
  /// de la tienda ([radioRecogidaKm] km desde la última posición GPS).
  Future<String?> confirmarRecogida() async {
    final distancia = distanciaLinealATiendaKm;
    if (distancia == null) {
      return 'Aún no hay señal GPS: no se puede verificar que estés en la tienda.';
    }
    if (distancia > radioRecogidaKm) {
      return 'Estás a ${distancia.toStringAsFixed(1)} km de la tienda. '
          'Debes estar a menos de ${radioRecogidaKm.toStringAsFixed(0)} km para confirmar la recogida.';
    }
    return _ejecutarAccion(() async {
      await _marcarRecogidoUseCase(_pedido!.id);
      _pedido = _pedido!.copyWith(estado: EstadoPedido.recogido);
      // El objetivo pasa a ser el cliente: recalcular de inmediato
      await _recalcularRutaDinamica(forzar: true);
    });
  }

  /// recogido → en_ruta_a_cliente
  Future<String?> iniciarRutaCliente() {
    return _ejecutarAccion(() async {
      await _iniciarRutaClienteUseCase(_pedido!.id);
      _pedido = _pedido!.copyWith(estado: EstadoPedido.enRutaACliente);
    });
  }

  /// en_ruta_a_cliente → entregado
  Future<String?> marcarEntregado() {
    if (_pedido?.repartidorId == null) return Future.value('Pedido sin repartidor');
    return _ejecutarAccion(() async {
      await _marcarEntregadoUseCase(_pedido!.id, _pedido!.repartidorId!);
      _pedido = _pedido!.copyWith(estado: EstadoPedido.entregado);
      _rutaDinamica = null;
      _puntosRutaDinamica = [];
    });
  }

  Future<String?> _ejecutarAccion(Future<void> Function() accion) async {
    if (_pedido == null || _procesandoAccion) return null;
    _procesandoAccion = true;
    notifyListeners();

    try {
      await accion();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _procesandoAccion = false;
      notifyListeners();
    }
  }

  /// Debe llamarse al salir de la pantalla del mapa.
  Future<void> limpiar() async {
    await _ubicacionSubscription?.cancel();
    _ubicacionSubscription = null;
    await _pedidoSubscription?.cancel();
    _pedidoSubscription = null;
  }

  @override
  void dispose() {
    _ubicacionSubscription?.cancel();
    _pedidoSubscription?.cancel();
    super.dispose();
  }
}
