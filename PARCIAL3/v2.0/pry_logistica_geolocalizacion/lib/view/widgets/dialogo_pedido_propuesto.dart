import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/domain/entities/pedido_entity.dart';
import '../../viewmodel/repartidor_viewmodel.dart';
import '../../../core/utils/geo_utils.dart';

class DialogoPedidoPropuesto extends StatelessWidget {
  final PedidoEntity pedido;
  final String repartidorId;
  final double latRepartidor;
  final double lngRepartidor;

  const DialogoPedidoPropuesto({
    super.key,
    required this.pedido,
    required this.repartidorId,
    required this.latRepartidor,
    required this.lngRepartidor,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RepartidorViewModel>();
    
    final dist = GeoUtils.calcularDistanciaHaversine(
      latRepartidor,
      lngRepartidor,
      pedido.latOrigen,
      pedido.lngOrigen,
    );

    return AlertDialog(
      title: const Text('¡Nuevo Pedido Asignado!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cliente: ${pedido.clienteNombre}'),
          const SizedBox(height: 8),
          Text('Recoger en: ${pedido.direccionOrigen}'),
          const SizedBox(height: 4),
          Text('Distancia al restaurante: ${dist.toStringAsFixed(2)} km'),
          const SizedBox(height: 8),
          Text('Entregar en: ${pedido.direccionDestino}'),
        ],
      ),
      actions: viewModel.isProcessing
          ? [const Center(child: CircularProgressIndicator())]
          : [
              TextButton(
                onPressed: () {
                  context.read<RepartidorViewModel>().rechazarPedidoPropuesto(repartidorId);
                },
                child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<RepartidorViewModel>().aceptarPedidoPropuesto(repartidorId);
                },
                child: const Text('Aceptar'),
              ),
            ],
    );
  }
}
