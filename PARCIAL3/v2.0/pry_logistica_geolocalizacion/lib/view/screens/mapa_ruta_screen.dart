import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../model/domain/entities/pedido_entity.dart';
import '../../viewmodel/mapa_viewmodel.dart';

/// Mapa de ruta del pedido: tienda, cliente, ruta base tienda→cliente y el
/// tramo dinámico desde la posición en vivo del repartidor (Firebase RTDB)
/// hacia su objetivo actual (tienda antes de recoger, cliente después).
/// La usan tanto el repartidor (con acciones de estado) como el administrador
/// (solo seguimiento).
class MapaRutaScreen extends StatefulWidget {
  final PedidoEntity pedido;
  final bool esRepartidor;

  const MapaRutaScreen({
    super.key,
    required this.pedido,
    required this.esRepartidor,
  });

  @override
  State<MapaRutaScreen> createState() => _MapaRutaScreenState();
}

class _MapaRutaScreenState extends State<MapaRutaScreen> {
  final MapController _mapController = MapController();
  late final MapaViewModel _mapaViewModel;
  bool _encuadreAplicado = false;

  @override
  void initState() {
    super.initState();
    _mapaViewModel = context.read<MapaViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapaViewModel.cargar(widget.pedido);
    });
  }

  @override
  void dispose() {
    _mapaViewModel.limpiar();
    super.dispose();
  }

  LatLng get _origen => LatLng(widget.pedido.latOrigen, widget.pedido.lngOrigen);
  LatLng get _destino => LatLng(widget.pedido.latDestino, widget.pedido.lngDestino);

  /// Encuadra la cámara para que se vea toda la ruta la primera vez que carga.
  void _ajustarEncuadre(List<LatLng> puntosCrudos) {
    // Nunca alimentar el mapa con coordenadas inválidas (evita asserts de LatLngBounds)
    final puntos = puntosCrudos
        .where((p) => p.latitude.abs() <= 90 && p.longitude.abs() <= 180)
        .toList();
    if (_encuadreAplicado || puntos.isEmpty) return;
    _encuadreAplicado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(puntos),
          padding: const EdgeInsets.fromLTRB(50, 80, 50, 220),
        ),
      );
    });
  }

  void _centrarEnRepartidor() {
    final ubicacion = _mapaViewModel.ubicacionRepartidor;
    if (ubicacion != null) {
      _mapController.move(LatLng(ubicacion.lat, ubicacion.lng), 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esRepartidor ? 'Mi Ruta de Entrega' : 'Seguimiento en Vivo'),
      ),
      body: Consumer<MapaViewModel>(
        builder: (context, viewModel, child) {
          final puntosBase =
              viewModel.puntosRutaBase.map((p) => LatLng(p[0], p[1])).toList();
          final puntosDinamica =
              viewModel.puntosRutaDinamica.map((p) => LatLng(p[0], p[1])).toList();
          _ajustarEncuadre([_origen, _destino, ...puntosBase, ...puntosDinamica]);

          final ubicacion = viewModel.ubicacionRepartidor;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    (widget.pedido.latOrigen + widget.pedido.latDestino) / 2,
                    (widget.pedido.lngOrigen + widget.pedido.lngDestino) / 2,
                  ),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.pry_logistica_geolocalizacion',
                  ),
                  PolylineLayer(
                    polylines: [
                      // Ruta base tienda→cliente (tramo pendiente del recorrido)
                      if (puntosBase.isNotEmpty)
                        Polyline(
                          points: puntosBase,
                          strokeWidth: 5,
                          color: AppTheme.colorAcento.withValues(alpha: 0.75),
                        ),
                      // Tramo dinámico: repartidor → objetivo actual
                      if (puntosDinamica.isNotEmpty)
                        Polyline(
                          points: puntosDinamica,
                          strokeWidth: 5,
                          color: AppTheme.colorPrimario.withValues(alpha: 0.85),
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      _marcador(_origen, Icons.storefront, Colors.deepOrange),
                      _marcador(_destino, Icons.location_on, Colors.red),
                      if (ubicacion != null)
                        Marker(
                          point: LatLng(ubicacion.lat, ubicacion.lng),
                          width: 52,
                          height: 52,
                          child: _MarcadorRepartidor(heading: ubicacion.heading),
                        ),
                    ],
                  ),
                ],
              ),

              // Barra superior de estado de carga / error de la ruta
              if (viewModel.state == MapaState.cargandoRuta)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
              if (viewModel.state == MapaState.error)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No se pudo calcular la ruta: ${viewModel.errorMessage ?? ''}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () => viewModel.cargar(widget.pedido),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Panel inferior con datos del pedido y acciones
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _PanelPedido(
                  viewModel: viewModel,
                  esRepartidor: widget.esRepartidor,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 200),
        child: FloatingActionButton.small(
          heroTag: 'centrarRepartidor',
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.colorPrimario,
          tooltip: 'Centrar en el repartidor',
          onPressed: _centrarEnRepartidor,
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }

  Marker _marcador(LatLng punto, IconData icono, Color color) {
    return Marker(
      point: punto,
      width: 44,
      height: 44,
      child: Icon(icono, color: color, size: 40, shadows: const [
        Shadow(color: Colors.black38, blurRadius: 6),
      ]),
    );
  }
}

/// Marcador circular del repartidor con flecha orientada según el rumbo GPS.
class _MarcadorRepartidor extends StatelessWidget {
  final double? heading;

  const _MarcadorRepartidor({this.heading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colorPrimario,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
      ),
      child: Transform.rotate(
        angle: (heading ?? 0) * math.pi / 180,
        child: const Icon(Icons.navigation, color: Colors.white, size: 26),
      ),
    );
  }
}

class _PanelPedido extends StatelessWidget {
  final MapaViewModel viewModel;
  final bool esRepartidor;

  const _PanelPedido({required this.viewModel, required this.esRepartidor});

  @override
  Widget build(BuildContext context) {
    final pedido = viewModel.pedido;
    if (pedido == null) return const SizedBox.shrink();

    final estadoRaw = PedidoEntity.estadoToString(pedido.estado);
    final ubicacion = viewModel.ubicacionRepartidor;
    final distanciaTotal = viewModel.distanciaTotalKm;
    final duracionTotal = viewModel.duracionTotalMin;

    final esRumboATienda = pedido.estado == EstadoPedido.asignado ||
        pedido.estado == EstadoPedido.enRutaATienda;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pedido.clienteNombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.storefront, size: 16, color: Colors.deepOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(pedido.direccionOrigen,
                      style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(pedido.direccionDestino,
                      style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (distanciaTotal != null && duracionTotal != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Dato(
                    icono: Icons.route,
                    texto: '${distanciaTotal.toStringAsFixed(1)} km',
                  ),
                  _Dato(
                    icono: Icons.schedule,
                    texto: '${duracionTotal.round()} min',
                  ),
                  if (ubicacion?.speed != null)
                    _Dato(
                      icono: Icons.speed,
                      texto: '${(ubicacion!.speed! * 3.6).toStringAsFixed(0)} km/h',
                    ),
                ],
              ),
              // Desglose del tramo actual cuando va rumbo a la tienda
              // (el total ya incluye tienda→cliente).
              if (esRumboATienda && viewModel.distanciaTramoKm != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'A la tienda: ${viewModel.distanciaTramoKm!.toStringAsFixed(1)} km '
                    '· ${viewModel.duracionTramoMin!.round()} min '
                    '(total incluye tienda → cliente)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
            if (!esRepartidor) ...[
              const SizedBox(height: 8),
              Text(
                ubicacion == null
                    ? 'Esperando la primera señal GPS del repartidor…'
                    : 'Última actualización: ${_tiempoRelativo(ubicacion.timestamp)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
            if (esRepartidor) ...[
              const SizedBox(height: 12),
              _BotonAccion(viewModel: viewModel),
            ],
          ],
        ),
      ),
    );
  }

  static String _tiempoRelativo(int timestamp) {
    final diferencia = DateTime.now().millisecondsSinceEpoch - timestamp;
    final segundos = (diferencia / 1000).round();
    if (segundos < 10) return 'ahora mismo';
    if (segundos < 60) return 'hace $segundos segundos';
    final minutos = (segundos / 60).round();
    return 'hace $minutos min';
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Dato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 18, color: AppTheme.colorPrimario),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Botón de transición de estado del repartidor:
/// asignado → en ruta a tienda → recogido (≤ 5 km de la tienda)
/// → en ruta a cliente → entregado.
class _BotonAccion extends StatelessWidget {
  final MapaViewModel viewModel;

  const _BotonAccion({required this.viewModel});

  Future<void> _ejecutar(
      BuildContext context, Future<String?> Function() accion,
      {String? exito}) async {
    final error = await accion();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
    } else if (exito != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exito)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = viewModel.pedido!;

    if (viewModel.procesandoAccion) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (pedido.estado) {
      case EstadoPedido.asignado:
        return ElevatedButton.icon(
          icon: const Icon(Icons.storefront),
          label: const Text('Ir a la tienda'),
          onPressed: () => _ejecutar(context, viewModel.irATienda),
        );
      case EstadoPedido.enRutaATienda:
        final distancia = viewModel.distanciaLinealATiendaKm;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    viewModel.dentroDeRangoRecogida ? Colors.deepOrange : Colors.grey,
              ),
              label: const Text('Confirmar recogida'),
              onPressed: () => _ejecutar(
                context,
                viewModel.confirmarRecogida,
                exito: 'Pedido recogido. ¡Ahora al cliente!',
              ),
            ),
            if (distancia != null && !viewModel.dentroDeRangoRecogida)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Estás a ${distancia.toStringAsFixed(1)} km de la tienda '
                  '(máx. ${MapaViewModel.radioRecogidaKm.toStringAsFixed(0)} km para recoger)',
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      case EstadoPedido.recogido:
        return ElevatedButton.icon(
          icon: const Icon(Icons.navigation),
          label: const Text('Iniciar ruta al cliente'),
          onPressed: () => _ejecutar(context, viewModel.iniciarRutaCliente),
        );
      case EstadoPedido.enRutaACliente:
        return ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          label: const Text('Marcar como entregado'),
          onPressed: () => _ejecutar(
            context,
            viewModel.marcarEntregado,
            exito: '¡Pedido entregado con éxito!',
          ),
        );
      case EstadoPedido.entregado:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Pedido entregado',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
