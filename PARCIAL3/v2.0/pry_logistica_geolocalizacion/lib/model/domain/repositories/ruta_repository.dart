import '../entities/pedido_entity.dart';
import '../entities/ruta_entity.dart';

abstract class RutaRepository {
  /// Devuelve la ruta origen→destino de un pedido. Si ya existe en Firebase
  /// la reutiliza; si no, la calcula contra la API REST de rutas (OSRM)
  /// y la persiste para las siguientes consultas.
  Future<RutaEntity> obtenerRutaDePedido(PedidoEntity pedido);

  /// Calcula la ruta en carretera entre dos puntos arbitrarios (p. ej.
  /// posición actual del repartidor → tienda) sin cachearla, porque el
  /// punto de partida cambia con cada movimiento del repartidor.
  Future<RutaEntity> calcularRutaDirecta({
    required double latOrigen,
    required double lngOrigen,
    required double latDestino,
    required double lngDestino,
  });
}
