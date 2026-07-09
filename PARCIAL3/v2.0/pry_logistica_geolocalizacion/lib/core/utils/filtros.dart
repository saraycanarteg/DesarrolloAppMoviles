import '../../model/domain/entities/pedido_entity.dart';
import '../../model/domain/entities/repartidor_entity.dart';

/// Filtros de las listas del panel de administrador (pestañas "Pedidos" y
/// "Repartidores"). Son funciones puras sobre las listas que ya llegan por
/// los streams de Firebase, para poder probarlas sin Flutter ni Firebase.
class Filtros {
  static bool _contiene(String? valor, String consulta) {
    if (valor == null) return false;
    return valor.toLowerCase().contains(consulta);
  }

  /// Búsqueda por nombre o cédula + filtros por tipo de vehículo y
  /// disponibilidad (null = no filtrar por ese criterio).
  static List<RepartidorEntity> repartidores(
    List<RepartidorEntity> lista, {
    String consulta = '',
    String? tipoVehiculo,
    bool? disponible,
  }) {
    final q = consulta.trim().toLowerCase();
    return lista.where((r) {
      if (q.isNotEmpty && !_contiene(r.nombre, q) && !_contiene(r.cedula, q)) {
        return false;
      }
      if (tipoVehiculo != null && r.vehiculoTipo != tipoVehiculo) return false;
      if (disponible != null && r.disponible != disponible) return false;
      return true;
    }).toList();
  }

  /// Búsqueda por nombre del cliente o del repartidor + filtros por estado
  /// y por rango de fechas de creación (inclusive en ambos extremos; solo
  /// cuenta el día, no la hora).
  static List<PedidoEntity> pedidos(
    List<PedidoEntity> lista, {
    String consulta = '',
    EstadoPedido? estado,
    DateTime? desde,
    DateTime? hasta,
  }) {
    final q = consulta.trim().toLowerCase();
    final inicio = desde != null ? DateTime(desde.year, desde.month, desde.day) : null;
    // Exclusivo: medianoche del día siguiente al final del rango.
    final fin = hasta != null ? DateTime(hasta.year, hasta.month, hasta.day + 1) : null;

    return lista.where((p) {
      if (q.isNotEmpty &&
          !_contiene(p.clienteNombre, q) &&
          !_contiene(p.repartidorNombre, q)) {
        return false;
      }
      if (estado != null && p.estado != estado) return false;

      if (inicio != null || fin != null) {
        final creado = DateTime.fromMillisecondsSinceEpoch(p.creadoEn);
        if (inicio != null && creado.isBefore(inicio)) return false;
        if (fin != null && !creado.isBefore(fin)) return false;
      }
      return true;
    }).toList();
  }
}
