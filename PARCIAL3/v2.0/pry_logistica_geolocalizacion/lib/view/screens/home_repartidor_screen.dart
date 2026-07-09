import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../model/domain/entities/repartidor_entity.dart';
import '../../model/domain/entities/pedido_entity.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/repartidor_viewmodel.dart';
import '../../viewmodel/tracking_viewmodel.dart';
import '../widgets/dialogo_pedido_propuesto.dart';
import 'detalle_pedido_screen.dart';
import 'login_screen.dart';
import 'mapa_ruta_screen.dart';
import 'mi_perfil_screen.dart';

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
      // Encender el GPS apenas inicia sesión: así el algoritmo de asignación
      // por cercanía (Haversine) siempre tiene la ubicación real del repartidor.
      context.read<TrackingViewModel>().iniciar(widget.repartidor.uid);
    });
  }

  Future<void> _cerrarSesion() async {
    await context.read<TrackingViewModel>().detener();
    if (!mounted) return;
    context.read<AuthViewModel>().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Repartidor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Mi Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MiPerfilScreen(repartidor: widget.repartidor),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          )
        ],
      ),
      body: Consumer2<RepartidorViewModel, TrackingViewModel>(
        builder: (context, viewModel, tracking, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TarjetaPerfil(repartidor: widget.repartidor, tracking: tracking),
                    const SizedBox(height: 16),
                    if (viewModel.pedidoActual != null)
                      _PedidoActualCard(pedido: viewModel.pedidoActual!)
                    else
                      const _SinPedidos(),
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
                      // Ubicación real del GPS (si aún no hay señal, se usa el
                      // origen del pedido para no mostrar distancias absurdas)
                      latRepartidor: tracking.ultimaUbicacion?.lat ??
                          viewModel.pedidoPropuesto!.latOrigen,
                      lngRepartidor: tracking.ultimaUbicacion?.lng ??
                          viewModel.pedidoPropuesto!.lngOrigen,
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

class _TarjetaPerfil extends StatelessWidget {
  final RepartidorEntity repartidor;
  final TrackingViewModel tracking;

  const _TarjetaPerfil({required this.repartidor, required this.tracking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.colorPrimario,
                  child: const Icon(Icons.sports_motorsports, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repartidor.nombre,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (repartidor.vehiculo != null)
                        Text(
                          repartidor.vehiculo!,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _EstadoGps(tracking: tracking),
          ],
        ),
      ),
    );
  }
}

/// Indicador del estado del sensor GPS y de la última posición publicada.
class _EstadoGps extends StatelessWidget {
  final TrackingViewModel tracking;

  const _EstadoGps({required this.tracking});

  @override
  Widget build(BuildContext context) {
    final (icono, color, texto) = switch (tracking.state) {
      TrackingState.activo => (
          Icons.gps_fixed,
          Colors.green,
          'GPS activo — transmitiendo ubicación en tiempo real',
        ),
      TrackingState.iniciando => (
          Icons.gps_not_fixed,
          Colors.orange,
          'Obteniendo señal GPS…',
        ),
      TrackingState.error => (
          Icons.gps_off,
          Colors.red,
          tracking.errorMessage ?? 'Error de GPS',
        ),
      TrackingState.inactivo => (
          Icons.gps_off,
          Colors.grey,
          'GPS inactivo',
        ),
    };

    return Row(
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(texto, style: TextStyle(color: color, fontSize: 13)),
        ),
        if (tracking.ultimaUbicacion != null)
          Text(
            '(${tracking.ultimaUbicacion!.lat.toStringAsFixed(5)}, '
            '${tracking.ultimaUbicacion!.lng.toStringAsFixed(5)})',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
      ],
    );
  }
}

class _SinPedidos extends StatelessWidget {
  const _SinPedidos();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No tienes pedidos asignados.\nEsperando nuevas entregas…',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _PedidoActualCard extends StatelessWidget {
  final PedidoEntity pedido;

  const _PedidoActualCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final estadoRaw = PedidoEntity.estadoToString(pedido.estado);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.colorPrimario, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mi Pedido Actual',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.colorPrimario,
                  ),
                ),
                Chip(
                  label: Text(EstadoPedidoUi.etiqueta(estadoRaw)),
                  backgroundColor: EstadoPedidoUi.color(estadoRaw),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cliente: ${pedido.clienteNombre}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.storefront, color: Colors.deepOrange),
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Ver mapa de ruta'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapaRutaScreen(pedido: pedido, esRepartidor: true),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.timeline),
              label: const Text('Ver estado del pedido'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DetallePedidoScreen(pedido: pedido, esRepartidor: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
