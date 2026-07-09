import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../model/domain/entities/pedido_entity.dart';
import '../../viewmodel/pedido_viewmodel.dart';
import 'mapa_ruta_screen.dart';

/// Estado del pedido: línea de tiempo del ciclo de vida
/// (pendiente → asignado → en ruta → entregado) actualizada en tiempo real
/// desde la RTDB, con los datos del cliente, direcciones y repartidor.
class DetallePedidoScreen extends StatelessWidget {
  final PedidoEntity pedido;
  final bool esRepartidor;

  const DetallePedidoScreen({
    super.key,
    required this.pedido,
    required this.esRepartidor,
  });

  @override
  Widget build(BuildContext context) {
    final pedidoViewModel = context.read<PedidoViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Estado del Pedido')),
      // Escucha el nodo de pedidos para que la línea de tiempo avance sola
      // cuando el repartidor acepta, inicia la ruta o confirma la entrega.
      body: StreamBuilder<List<PedidoEntity>>(
        stream: pedidoViewModel.todosLosPedidos,
        builder: (context, snapshot) {
          final actualizado = snapshot.data
                  ?.where((p) => p.id == pedido.id)
                  .toList() ??
              [];
          final p = actualizado.isNotEmpty ? actualizado.first : pedido;
          final estadoRaw = PedidoEntity.estadoToString(p.estado);
          final puedeVerMapa = p.repartidorId != null && p.enCurso;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p.clienteNombre,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(
                            label: Text(EstadoPedidoUi.etiqueta(estadoRaw)),
                            backgroundColor: EstadoPedidoUi.color(estadoRaw),
                            labelStyle:
                                const TextStyle(color: Colors.white, fontSize: 12),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _FilaDato(
                        icono: Icons.storefront,
                        color: Colors.deepOrange,
                        texto: 'Origen: ${p.direccionOrigen}',
                      ),
                      const SizedBox(height: 8),
                      _FilaDato(
                        icono: Icons.location_on,
                        color: Colors.red,
                        texto: 'Destino: ${p.direccionDestino}',
                      ),
                      if (p.repartidorNombre != null) ...[
                        const SizedBox(height: 8),
                        _FilaDato(
                          icono: Icons.sports_motorsports,
                          color: AppTheme.colorPrimario,
                          texto:
                              'Repartidor: ${p.repartidorNombre}${p.repartidorVehiculo != null ? ' (${p.repartidorVehiculo})' : ''}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seguimiento de la entrega',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _LineaDeTiempo(pedido: p),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (puedeVerMapa)
                ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: Text(esRepartidor
                      ? 'Ver mapa de ruta'
                      : 'Ver ubicación del repartidor en vivo'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MapaRutaScreen(pedido: p, esRepartidor: esRepartidor),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;

  const _FilaDato({required this.icono, required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(texto)),
      ],
    );
  }
}

/// Línea de tiempo vertical con los hitos del pedido y sus timestamps.
class _LineaDeTiempo extends StatelessWidget {
  final PedidoEntity pedido;

  const _LineaDeTiempo({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final indiceEstado = switch (pedido.estado) {
      EstadoPedido.pendiente => 0,
      EstadoPedido.esperandoConfirmacion => 1,
      EstadoPedido.asignado => 1,
      EstadoPedido.enRutaATienda => 2,
      EstadoPedido.recogido => 3,
      EstadoPedido.enRutaACliente => 4,
      EstadoPedido.entregado => 5,
    };

    final pasos = [
      (
        titulo: 'Pedido registrado',
        detalle: _formatearFecha(pedido.creadoEn),
        icono: Icons.receipt_long,
      ),
      (
        titulo: pedido.estado == EstadoPedido.esperandoConfirmacion
            ? 'Esperando confirmación del repartidor'
            : 'Repartidor asignado',
        detalle: _formatearFecha(pedido.asignadoEn),
        icono: Icons.person_pin_circle,
      ),
      (
        titulo: 'En ruta a la tienda',
        detalle: _formatearFecha(pedido.enRutaEn),
        icono: Icons.storefront,
      ),
      (
        titulo: 'Pedido recogido en la tienda',
        detalle: _formatearFecha(pedido.recogidoEn),
        icono: Icons.shopping_bag,
      ),
      (
        titulo: 'En ruta hacia el cliente',
        detalle: _formatearFecha(pedido.enRutaClienteEn),
        icono: Icons.local_shipping,
      ),
      (
        titulo: 'Entregado al cliente',
        detalle: _formatearFecha(pedido.entregadoEn),
        icono: Icons.check_circle,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < pasos.length; i++)
          _PasoTimeline(
            titulo: pasos[i].titulo,
            detalle: pasos[i].detalle,
            icono: pasos[i].icono,
            completado: i <= indiceEstado,
            esActual: i == indiceEstado,
            esUltimo: i == pasos.length - 1,
          ),
      ],
    );
  }

  static String? _formatearFecha(int? millis) {
    if (millis == null || millis <= 0) return null;
    final fecha = DateTime.fromMillisecondsSinceEpoch(millis);
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    return '${dosDigitos(fecha.day)}/${dosDigitos(fecha.month)}/${fecha.year} '
        '${dosDigitos(fecha.hour)}:${dosDigitos(fecha.minute)}';
  }
}

class _PasoTimeline extends StatelessWidget {
  final String titulo;
  final String? detalle;
  final IconData icono;
  final bool completado;
  final bool esActual;
  final bool esUltimo;

  const _PasoTimeline({
    required this.titulo,
    required this.detalle,
    required this.icono,
    required this.completado,
    required this.esActual,
    required this.esUltimo,
  });

  @override
  Widget build(BuildContext context) {
    final color = completado ? AppTheme.colorPrimario : Colors.grey.shade400;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color,
                child: Icon(icono, size: 18, color: Colors.white),
              ),
              if (!esUltimo)
                Expanded(
                  child: Container(
                    width: 2,
                    color: completado && !esActual ? AppTheme.colorPrimario : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: esActual ? FontWeight.bold : FontWeight.w500,
                      color: completado ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                  if (detalle != null)
                    Text(
                      detalle!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
