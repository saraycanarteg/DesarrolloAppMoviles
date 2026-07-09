import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../model/domain/entities/direccion_entity.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/pedido_viewmodel.dart';
import '../../viewmodel/registro_pedido_viewmodel.dart';

/// Registro de pedidos (admin): formulario validado + selección de
/// origen y destino sincronizada en ambos sentidos con el mapa (OSM):
/// - Tocar el mapa llena automáticamente el campo de dirección (Nominatim).
/// - Escribir la dirección y buscarla posiciona el marcador en el mapa.
/// Solo se aceptan ubicaciones dentro de Ecuador.
class RegistroPedidoScreen extends StatefulWidget {
  const RegistroPedidoScreen({super.key});

  @override
  State<RegistroPedidoScreen> createState() => _RegistroPedidoScreenState();
}

class _RegistroPedidoScreenState extends State<RegistroPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _direccionOrigenController = TextEditingController();
  final _direccionDestinoController = TextEditingController();
  final MapController _mapController = MapController();

  // Centro inicial: Quito (zona La Carolina, sobre la trama urbana)
  static const LatLng _centroInicial = LatLng(-0.1900, -78.4850);

  CampoUbicacion _puntoEnEdicion = CampoUbicacion.origen;
  bool _faltanPuntos = false;

  late final RegistroPedidoViewModel _registroViewModel;

  @override
  void initState() {
    super.initState();
    _registroViewModel = context.read<RegistroPedidoViewModel>();
    _registroViewModel.limpiar();
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _direccionOrigenController.dispose();
    _direccionDestinoController.dispose();
    super.dispose();
  }

  TextEditingController _controllerDe(CampoUbicacion campo) =>
      campo == CampoUbicacion.origen
          ? _direccionOrigenController
          : _direccionDestinoController;

  /// Mapa → formulario: valida el punto (Ecuador) y llena el campo de texto.
  Future<void> _alTocarMapa(TapPosition tapPosition, LatLng punto) async {
    final campo = _puntoEnEdicion;
    final direccion = await _registroViewModel.seleccionarPunto(
        campo, punto.latitude, punto.longitude);

    if (!mounted) return;
    if (direccion == null) {
      _mostrarErrorUbicacion();
      return;
    }

    setState(() {
      _controllerDe(campo).text = direccion.descripcion;
      // Comodidad: tras fijar el origen, pasar automáticamente al destino
      if (campo == CampoUbicacion.origen) {
        _puntoEnEdicion = CampoUbicacion.destino;
      }
      _faltanPuntos = false;
    });
  }

  /// Formulario → mapa: verifica que la dirección exista en Ecuador
  /// y posiciona el marcador correspondiente.
  Future<DireccionEntity?> _buscarDireccion(CampoUbicacion campo) async {
    FocusScope.of(context).unfocus();
    final direccion = await _registroViewModel.buscarDireccion(
        campo, _controllerDe(campo).text);

    if (!mounted) return direccion;
    if (direccion == null) {
      _mostrarErrorUbicacion();
      return null;
    }

    setState(() {
      _controllerDe(campo).text = direccion.descripcion;
      _faltanPuntos = false;
      // Al fijar el origen por búsqueda también pasamos al destino
      if (campo == CampoUbicacion.origen) {
        _puntoEnEdicion = CampoUbicacion.destino;
      }
    });
    _mapController.move(LatLng(direccion.lat, direccion.lng), 16);
    return direccion;
  }

  void _mostrarErrorUbicacion() {
    final mensaje = _registroViewModel.errorUbicacion;
    if (mensaje == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _guardar() async {
    final formularioValido = _formKey.currentState!.validate();
    if (!formularioValido) return;

    // Si escribieron la dirección pero nunca la buscaron ni tocaron el mapa,
    // intentamos geocodificarla aquí mismo antes de rechazar el registro.
    if (_registroViewModel.origen == null &&
        _direccionOrigenController.text.trim().isNotEmpty) {
      if (await _buscarDireccion(CampoUbicacion.origen) == null) return;
    }
    if (_registroViewModel.destino == null &&
        _direccionDestinoController.text.trim().isNotEmpty) {
      if (await _buscarDireccion(CampoUbicacion.destino) == null) return;
    }
    if (!mounted) return;

    final origen = _registroViewModel.origen;
    final destino = _registroViewModel.destino;
    final puntosCompletos = origen != null && destino != null;
    setState(() => _faltanPuntos = !puntosCompletos);
    if (!puntosCompletos) return;

    final authViewModel = context.read<AuthViewModel>();
    final pedidoViewModel = context.read<PedidoViewModel>();

    final creado = await pedidoViewModel.crearPedido(
      clienteNombre: _clienteController.text.trim(),
      direccionOrigen: _direccionOrigenController.text.trim(),
      latOrigen: origen.lat,
      lngOrigen: origen.lng,
      direccionDestino: _direccionDestinoController.text.trim(),
      latDestino: destino.lat,
      lngDestino: destino.lng,
      creadoPor: authViewModel.sesion?.usuario.uid ?? '',
    );

    if (creado && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido registrado. Ya puedes asignarlo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoViewModel = context.watch<PedidoViewModel>();
    final registroViewModel = context.watch<RegistroPedidoViewModel>();

    final origen = registroViewModel.origen;
    final destino = registroViewModel.destino;
    final ocupado = registroViewModel.procesando ||
        pedidoViewModel.state == PedidoViewModelState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Pedido')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _clienteController,
              decoration: const InputDecoration(
                labelText: 'Nombre del cliente',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa el nombre del cliente' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direccionOrigenController,
              decoration: InputDecoration(
                labelText: 'Dirección de origen (tienda/restaurante)',
                prefixIcon: const Icon(Icons.storefront),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar en el mapa',
                  onPressed: ocupado
                      ? null
                      : () => _buscarDireccion(CampoUbicacion.origen),
                ),
              ),
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => _buscarDireccion(CampoUbicacion.origen),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa la dirección de origen' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direccionDestinoController,
              decoration: InputDecoration(
                labelText: 'Dirección de entrega',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar en el mapa',
                  onPressed: ocupado
                      ? null
                      : () => _buscarDireccion(CampoUbicacion.destino),
                ),
              ),
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => _buscarDireccion(CampoUbicacion.destino),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa la dirección de entrega' : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<CampoUbicacion>(
              segments: [
                ButtonSegment(
                  value: CampoUbicacion.origen,
                  icon: const Icon(Icons.storefront),
                  label: Text(origen == null ? 'Fijar origen' : 'Origen ✓'),
                ),
                ButtonSegment(
                  value: CampoUbicacion.destino,
                  icon: const Icon(Icons.location_on),
                  label: Text(destino == null ? 'Fijar destino' : 'Destino ✓'),
                ),
              ],
              selected: {_puntoEnEdicion},
              onSelectionChanged: (seleccion) {
                setState(() => _puntoEnEdicion = seleccion.first);
              },
            ),
            const SizedBox(height: 8),
            Text(
              _puntoEnEdicion == CampoUbicacion.origen
                  ? 'Toca el mapa para marcar dónde se RECOGE el pedido'
                  : 'Toca el mapa para marcar dónde se ENTREGA el pedido',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _centroInicial,
                        initialZoom: 13,
                        onTap: _alTocarMapa,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.pry_logistica_geolocalizacion',
                        ),
                        MarkerLayer(
                          markers: [
                            if (origen != null)
                              Marker(
                                point: LatLng(origen.lat, origen.lng),
                                width: 44,
                                height: 44,
                                child: const Icon(Icons.storefront,
                                    color: Colors.deepOrange, size: 40),
                              ),
                            if (destino != null)
                              Marker(
                                point: LatLng(destino.lat, destino.lng),
                                width: 44,
                                height: 44,
                                child: const Icon(Icons.location_on,
                                    color: Colors.red, size: 40),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (registroViewModel.procesando)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            if (registroViewModel.errorUbicacion != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  registroViewModel.errorUbicacion!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_faltanPuntos)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Debes fijar el origen y el destino (tocando el mapa o buscando la dirección)',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (pedidoViewModel.state == PedidoViewModelState.error &&
                pedidoViewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  pedidoViewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: ocupado
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Registrar pedido'),
              onPressed: ocupado ? null : _guardar,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
