import '../../domain/entities/pedido_entity.dart';
import '../../domain/entities/ruta_entity.dart';
import '../../domain/repositories/ruta_repository.dart';
import '../datasources/database_remote_datasource.dart';
import '../datasources/ruta_remote_datasource.dart';

class RutaRepositoryImpl implements RutaRepository {
  final RutaRemoteDataSource rutaDataSource;
  final DatabaseRemoteDataSource databaseDataSource;

  RutaRepositoryImpl(this.rutaDataSource, this.databaseDataSource);

  @override
  Future<RutaEntity> obtenerRutaDePedido(PedidoEntity pedido) async {
    // 1. Cache: si la ruta ya fue calculada, se reutiliza desde Firebase
    final existente = await databaseDataSource.obtenerRutaDePedido(pedido.id);
    if (existente != null && existente.polylineCodificado.isNotEmpty) {
      return existente;
    }

    // 2. Consumir la API REST (OSRM) y persistir el resultado
    final calculada = await rutaDataSource.calcularRuta(
      pedidoId: pedido.id,
      repartidorId: pedido.repartidorId ?? '',
      latOrigen: pedido.latOrigen,
      lngOrigen: pedido.lngOrigen,
      latDestino: pedido.latDestino,
      lngDestino: pedido.lngDestino,
    );

    try {
      await databaseDataSource.guardarRutaDePedido(calculada);
    } catch (_) {
      // Si no se pudo guardar (p. ej. permisos), igual devolvemos la ruta calculada
    }

    return calculada;
  }

  @override
  Future<RutaEntity> calcularRutaDirecta({
    required double latOrigen,
    required double lngOrigen,
    required double latDestino,
    required double lngDestino,
  }) {
    return rutaDataSource.calcularRuta(
      pedidoId: '',
      repartidorId: '',
      latOrigen: latOrigen,
      lngOrigen: lngOrigen,
      latDestino: latDestino,
      lngDestino: lngDestino,
    );
  }
}
