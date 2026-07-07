import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/pedido_viewmodel.dart';
import '../../model/domain/entities/pedido_entity.dart';
import 'login_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
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
      body: _currentIndex == 0 ? const _DashboardView() : const _PedidosView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidoViewModel>(
      builder: (context, pedidoViewModel, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bienvenido, Administrador', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Asignación Manual'),
                  Switch(
                    value: pedidoViewModel.isAsignacionAutomatica,
                    onChanged: (val) {
                      pedidoViewModel.toggleAsignacionAutomatica(val);
                    },
                  ),
                  const Text('Automática'),
                ],
              ),
              const SizedBox(height: 16),
              // Botón de prueba (ahora pueden usar la vista de Pedidos para asignar reales)
              ElevatedButton(
                onPressed: () {
                  pedidoViewModel.asignarPedido('-Owtu0ksq2G-U-dUwKRs'); // ID de prueba proporcionado
                },
                child: const Text('Asignar Pedido de Prueba'),
              ),
              if (pedidoViewModel.state == PedidoViewModelState.loading)
                const CircularProgressIndicator(),
              if (pedidoViewModel.state == PedidoViewModelState.error && pedidoViewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(pedidoViewModel.errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
              if (pedidoViewModel.state == PedidoViewModelState.success)
                const Text('Asignación procesada', style: TextStyle(color: Colors.green)),
            ],
          ),
        );
      },
    );
  }
}

class _PedidosView extends StatelessWidget {
  const _PedidosView();

  @override
  Widget build(BuildContext context) {
    final pedidoViewModel = context.read<PedidoViewModel>();

    return StreamBuilder<List<PedidoEntity>>(
      stream: pedidoViewModel.todosLosPedidos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error cargando pedidos'));
        }
        
        final pedidos = snapshot.data ?? [];
        if (pedidos.isEmpty) {
          return const Center(child: Text('No hay pedidos registrados'));
        }

        return ListView.builder(
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final p = pedidos[index];
            final colorEstado = p.estado == EstadoPedido.pendiente 
                ? Colors.orange 
                : (p.estado == EstadoPedido.esperandoConfirmacion ? Colors.blue : Colors.green);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text('Cliente: ${p.clienteNombre}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('De: ${p.direccionOrigen}'),
                    Text('A: ${p.direccionDestino}'),
                    if (p.repartidorNombre != null) 
                      Text('Asignado a: ${p.repartidorNombre}${p.repartidorVehiculo != null ? ' (${p.repartidorVehiculo})' : ''}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    const SizedBox(height: 4),
                    Text('ID: ${p.id}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    PedidoEntity.estadoToString(p.estado),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: colorEstado,
                ),
                onTap: () {
                  if (p.estado == EstadoPedido.pendiente) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Asignar Pedido'),
                        content: Text('¿Deseas intentar asignar este pedido (${p.clienteNombre})?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              pedidoViewModel.asignarPedido(p.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Procesando asignación...')));
                            },
                            child: const Text('Asignar'),
                          )
                        ],
                      )
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
