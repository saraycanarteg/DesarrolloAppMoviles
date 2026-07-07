import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/domain/entities/repartidor_entity.dart';
import '../../model/domain/entities/pedido_entity.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/repartidor_viewmodel.dart';
import '../widgets/dialogo_pedido_propuesto.dart';
import 'login_screen.dart';

class HomeRepartidorScreen extends StatefulWidget {
  final RepartidorEntity repartidor;

  const HomeRepartidorScreen({
    super.key,
    required this.repartidor,
  });

  @override
  State<HomeRepartidorScreen> createState() => _HomeRepartidorScreenState();
}

class _HomeRepartidorScreenState extends State<HomeRepartidorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepartidorViewModel>().iniciarEscucha(widget.repartidor.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Repartidor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthViewModel>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Consumer<RepartidorViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Bienvenido, ${widget.repartidor.nombre}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Estado: ${widget.repartidor.disponible ? "Disponible" : "No disponible"}',
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.repartidor.disponible ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (widget.repartidor.vehiculo != null) Text('Vehículo: ${widget.repartidor.vehiculo}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (viewModel.pedidoActual != null)
                      _PedidoActualCard(pedido: viewModel.pedidoActual!)
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No tienes pedidos asignados actualmente. Esperando notificaciones...',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              if (viewModel.pedidoPropuesto != null)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: DialogoPedidoPropuesto(
                      pedido: viewModel.pedidoPropuesto!,
                      repartidorId: widget.repartidor.uid,
                      latRepartidor: -0.180653, // Coordenada mock (se integraría con GPS real)
                      lngRepartidor: -78.467834,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PedidoActualCard extends StatelessWidget {
  final PedidoEntity pedido;

  const _PedidoActualCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('¡Mi Pedido Actual!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                Chip(
                  label: Text(PedidoEntity.estadoToString(pedido.estado), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Cliente: ${pedido.clienteNombre}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.storefront, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(child: Text('Origen: ${pedido.direccionOrigen}')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text('Destino: ${pedido.direccionDestino}')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
