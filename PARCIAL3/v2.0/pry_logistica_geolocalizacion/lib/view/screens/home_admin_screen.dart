import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/vehiculo_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/filtros.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/gestion_repartidor_viewmodel.dart';
import '../../viewmodel/pedido_viewmodel.dart';
import '../../model/domain/entities/pedido_entity.dart';
import '../../model/domain/entities/repartidor_entity.dart';
import 'detalle_pedido_screen.dart';
import 'editar_repartidor_screen.dart';
import 'login_screen.dart';
import 'registro_pedido_screen.dart';
import 'registro_repartidor_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Notificar al admin cuando un repartidor confirme una entrega
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidoViewModel>().iniciarNotificacionesEntregas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              context.read<PedidoViewModel>().detenerNotificacionesEntregas();
              context.read<AuthViewModel>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: switch (_currentIndex) {
        0 => const _DashboardView(),
        1 => const _PedidosView(),
        _ => const _RepartidoresView(),
      },
      floatingActionButton: switch (_currentIndex) {
        1 => FloatingActionButton.extended(
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Nuevo pedido'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistroPedidoScreen()),
              );
            },
          ),
        2 => FloatingActionButton.extended(
            icon: const Icon(Icons.person_add),
            label: const Text('Nuevo repartidor'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistroRepartidorScreen()),
              );
            },
          ),
        _ => null,
      },
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
            icon: Icon(Icons.list_alt),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_motorsports),
            label: 'Repartidores',
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
    final pedidoViewModel = context.watch<PedidoViewModel>();

    return StreamBuilder<List<PedidoEntity>>(
      stream: pedidoViewModel.todosLosPedidos,
      builder: (context, snapshot) {
        final pedidos = snapshot.data ?? [];
        final pendientes = pedidos.where((p) => p.estado == EstadoPedido.pendiente).length;
        final enCurso = pedidos
            .where((p) => p.estado == EstadoPedido.esperandoConfirmacion || p.enCurso)
            .length;
        final entregados = pedidos.where((p) => p.estado == EstadoPedido.entregado).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Resumen operativo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _TarjetaMetrica(
                    titulo: 'Pendientes',
                    valor: pendientes,
                    icono: Icons.hourglass_top,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _TarjetaMetrica(
                    titulo: 'En curso',
                    valor: enCurso,
                    icono: Icons.local_shipping,
                    color: AppTheme.colorPrimario,
                  ),
                  const SizedBox(width: 12),
                  _TarjetaMetrica(
                    titulo: 'Entregados',
                    valor: entregados,
                    icono: Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modo de asignación de repartidores',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Manual'),
                          Switch(
                            value: pedidoViewModel.isAsignacionAutomatica,
                            onChanged: (val) {
                              pedidoViewModel.toggleAsignacionAutomatica(val);
                            },
                          ),
                          const Text('Automática (más cercano)'),
                        ],
                      ),
                      Text(
                        pedidoViewModel.isAsignacionAutomatica
                            ? 'Los pedidos se proponen al repartidor disponible más cercano al origen (fórmula de Haversine sobre las ubicaciones GPS en vivo).'
                            : 'Deberás elegir manualmente el repartidor para cada pedido.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (pedidoViewModel.state == PedidoViewModelState.loading)
                const Center(child: CircularProgressIndicator()),
              if (pedidoViewModel.state == PedidoViewModelState.error &&
                  pedidoViewModel.errorMessage != null)
                Text(
                  pedidoViewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),
              const Text(
                'Repartidores activos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const _ListaRepartidoresActivos(),
            ],
          ),
        );
      },
    );
  }
}

/// Lista en vivo de repartidores para el dashboard operativo: quiénes están
/// disponibles y quiénes tienen una entrega en curso.
class _ListaRepartidoresActivos extends StatelessWidget {
  const _ListaRepartidoresActivos();

  @override
  Widget build(BuildContext context) {
    final pedidoViewModel = context.read<PedidoViewModel>();

    return StreamBuilder<List<RepartidorEntity>>(
      stream: pedidoViewModel.repartidores,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final repartidores = snapshot.data!;
        if (repartidores.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aún no hay repartidores registrados.'),
            ),
          );
        }

        return Column(
          children: repartidores
              .map((r) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            r.disponible ? Colors.green : Colors.grey,
                        child: const Icon(Icons.sports_motorsports,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(r.nombre),
                      subtitle: Text(r.vehiculo ?? 'Sin vehículo registrado'),
                      trailing: _ChipEstadoRepartidor(repartidor: r),
                      dense: true,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _ChipEstadoRepartidor extends StatelessWidget {
  final RepartidorEntity repartidor;

  const _ChipEstadoRepartidor({required this.repartidor});

  @override
  Widget build(BuildContext context) {
    final (texto, color) = repartidor.pedidoActualId != null
        ? ('En entrega', Colors.orange)
        : repartidor.disponible
            ? ('Disponible', Colors.green)
            : ('No disponible', Colors.grey);

    return Chip(
      label: Text(texto),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      padding: EdgeInsets.zero,
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  final String titulo;
  final int valor;
  final IconData icono;
  final Color color;

  const _TarjetaMetrica({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icono, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                '$valor',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Text(titulo, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pestaña "Pedidos": listado en vivo con búsqueda por cliente o repartidor
/// y filtros por estado de la entrega y rango de fechas de creación.
class _PedidosView extends StatefulWidget {
  const _PedidosView();

  @override
  State<_PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<_PedidosView> {
  final _busquedaController = TextEditingController();
  String _consulta = '';
  String _estadoRaw = ''; // '' = todos los estados
  DateTimeRange? _rangoFechas;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _elegirRangoFechas() async {
    final hoy = DateTime.now();
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(hoy.year - 2),
      lastDate: DateTime(hoy.year, hoy.month, hoy.day),
      initialDateRange: _rangoFechas,
      helpText: 'Filtrar por fecha de creación',
      saveText: 'Aplicar',
    );
    if (rango != null) setState(() => _rangoFechas = rango);
  }

  Widget _barraFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _busquedaController,
            decoration: InputDecoration(
              hintText: 'Buscar por cliente o repartidor',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _consulta.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        _busquedaController.clear();
                        setState(() => _consulta = '');
                      },
                    ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _consulta = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _estadoRaw,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.flag_outlined),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Todos')),
                    ...EstadoPedido.values.map((e) {
                      final raw = PedidoEntity.estadoToString(e);
                      return DropdownMenuItem(
                        value: raw,
                        child: Text(
                          EstadoPedidoUi.etiqueta(raw),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (v) => setState(() => _estadoRaw = v ?? ''),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(
                    _rangoFechas == null
                        ? 'Fechas'
                        : '${_fecha(_rangoFechas!.start)} – ${_fecha(_rangoFechas!.end)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _elegirRangoFechas,
                ),
              ),
              if (_rangoFechas != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Quitar filtro de fechas',
                  onPressed: () => setState(() => _rangoFechas = null),
                ),
            ],
          ),
        ],
      ),
    );
  }

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

        final filtrados = Filtros.pedidos(
          pedidos,
          consulta: _consulta,
          estado: _estadoRaw.isEmpty ? null : PedidoEntity.stringToEstado(_estadoRaw),
          desde: _rangoFechas?.start,
          hasta: _rangoFechas?.end,
        );

        return Column(
          children: [
            _barraFiltros(),
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(
                      child: Text('Ningún pedido coincide con la búsqueda o los filtros.'),
                    )
                  : _listaPedidos(pedidoViewModel, filtrados),
            ),
          ],
        );
      },
    );
  }

  Widget _listaPedidos(PedidoViewModel pedidoViewModel, List<PedidoEntity> pedidos) {
    return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final p = pedidos[index];
            final estadoRaw = PedidoEntity.estadoToString(p.estado);
            final tieneSeguimiento = p.repartidorId != null && p.estado != EstadoPedido.pendiente;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: ListTile(
                title: Text(
                  p.clienteNombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('De: ${p.direccionOrigen}'),
                    Text('A: ${p.direccionDestino}'),
                    if (p.repartidorNombre != null)
                      Text(
                        'Repartidor: ${p.repartidorNombre}${p.repartidorVehiculo != null ? ' (${p.repartidorVehiculo})' : ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.colorPrimario,
                        ),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(EstadoPedidoUi.etiqueta(estadoRaw)),
                      backgroundColor: EstadoPedidoUi.color(estadoRaw),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      padding: EdgeInsets.zero,
                    ),
                    if (tieneSeguimiento)
                      const Icon(Icons.map, color: AppTheme.colorPrimario, size: 18),
                  ],
                ),
                onTap: () => _alTocarPedido(context, pedidoViewModel, p),
              ),
            );
          },
        );
  }

  void _alTocarPedido(
    BuildContext context,
    PedidoViewModel pedidoViewModel,
    PedidoEntity p,
  ) {
    if (p.estado == EstadoPedido.pendiente) {
      if (pedidoViewModel.isAsignacionAutomatica) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Asignar Pedido'),
            content: Text(
              '¿Deseas asignar este pedido (${p.clienteNombre}) '
              'al repartidor disponible más cercano?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  pedidoViewModel.asignarPedido(p.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Procesando asignación…')),
                  );
                },
                child: const Text('Asignar'),
              )
            ],
          ),
        );
      } else {
        _mostrarSelectorRepartidor(context, pedidoViewModel, p);
      }
    } else {
      // Pantalla de estado del pedido: línea de tiempo en vivo y, si hay
      // seguimiento activo, acceso al mapa con la posición del repartidor.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetallePedidoScreen(pedido: p, esRepartidor: false),
        ),
      );
    }
  }

  /// Diálogo de asignación manual: lista en vivo de repartidores,
  /// solo los disponibles son seleccionables.
  void _mostrarSelectorRepartidor(
    BuildContext context,
    PedidoViewModel pedidoViewModel,
    PedidoEntity p,
  ) {
    String? seleccionado;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Elegir repartidor'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<RepartidorEntity>>(
              stream: pedidoViewModel.repartidores,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final repartidores = snapshot.data!;
                if (repartidores.isEmpty) {
                  return const Text('No hay repartidores registrados.');
                }

                return RadioGroup<String>(
                  groupValue: seleccionado,
                  onChanged: (valor) => setState(() => seleccionado = valor),
                  child: ListView(
                    shrinkWrap: true,
                    children: repartidores.map((r) {
                      return RadioListTile<String>(
                        value: r.uid,
                        enabled: r.disponible,
                        title: Text(r.nombre),
                        subtitle: Text(
                          r.disponible
                              ? (r.vehiculo ?? 'Disponible')
                              : 'No disponible',
                          style: TextStyle(
                            color: r.disponible ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        dense: true,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: seleccionado == null
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      pedidoViewModel.asignarPedido(p.id, repartidorManualId: seleccionado);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Asignando repartidor…')),
                      );
                    },
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pestaña "Repartidores": listado en vivo con búsqueda por nombre o cédula,
/// filtros por tipo de vehículo y disponibilidad, y acciones de editar y
/// eliminar. El alta se hace con el botón "Nuevo repartidor" (módulo del
/// admin; no existe registro público de cuentas).
class _RepartidoresView extends StatefulWidget {
  const _RepartidoresView();

  @override
  State<_RepartidoresView> createState() => _RepartidoresViewState();
}

class _RepartidoresViewState extends State<_RepartidoresView> {
  final _busquedaController = TextEditingController();
  String _consulta = '';
  String _tipoVehiculo = ''; // '' = todos los tipos
  String _disponibilidad = ''; // '' = todos, 'si' / 'no'

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Widget _barraFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _busquedaController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o cédula',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _consulta.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        _busquedaController.clear();
                        setState(() => _consulta = '');
                      },
                    ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _consulta = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoVehiculo,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Vehículo',
                    prefixIcon: Icon(Icons.commute),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Todos')),
                    ...VehiculoConstants.tipos
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))),
                  ],
                  onChanged: (v) => setState(() => _tipoVehiculo = v ?? ''),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _disponibilidad,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Disponibilidad',
                    prefixIcon: Icon(Icons.toggle_on_outlined),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Todos')),
                    DropdownMenuItem(value: 'si', child: Text('Disponibles')),
                    DropdownMenuItem(value: 'no', child: Text('No disponibles')),
                  ],
                  onChanged: (v) => setState(() => _disponibilidad = v ?? ''),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(RepartidorEntity r) async {
    if (r.pedidoActualId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se puede eliminar a ${r.nombre}: tiene una entrega en curso.',
          ),
        ),
      );
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar repartidor'),
        content: Text(
          '¿Deseas eliminar a ${r.nombre} (cédula ${r.cedula ?? 'N/D'})? '
          'Se borrará su registro y ya no podrá recibir pedidos ni iniciar '
          'sesión en la app. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final viewModel = context.read<GestionRepartidorViewModel>();
    final eliminado = await viewModel.eliminarRepartidor(r.uid);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          eliminado
              ? 'Repartidor ${r.nombre} eliminado.'
              : viewModel.errorMessage ?? 'No se pudo eliminar el repartidor.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedidoViewModel = context.read<PedidoViewModel>();

    return StreamBuilder<List<RepartidorEntity>>(
      stream: pedidoViewModel.repartidores,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error cargando repartidores'));
        }

        final repartidores = snapshot.data ?? [];
        if (repartidores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No hay repartidores registrados.\nUsa "Nuevo repartidor" para crear el primero.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final filtrados = Filtros.repartidores(
          repartidores,
          consulta: _consulta,
          tipoVehiculo: _tipoVehiculo.isEmpty ? null : _tipoVehiculo,
          disponible: _disponibilidad.isEmpty ? null : _disponibilidad == 'si',
        );

        return Column(
          children: [
            _barraFiltros(),
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(
                      child: Text(
                        'Ningún repartidor coincide con la búsqueda o los filtros.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) =>
                          _tarjetaRepartidor(filtrados[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _tarjetaRepartidor(RepartidorEntity r) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: r.disponible ? Colors.green : Colors.grey,
                  child: const Icon(Icons.sports_motorsports,
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    r.nombre,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                _ChipEstadoRepartidor(repartidor: r),
                PopupMenuButton<String>(
                  tooltip: 'Opciones',
                  onSelected: (opcion) {
                    if (opcion == 'editar') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditarRepartidorScreen(repartidor: r),
                        ),
                      );
                    } else if (opcion == 'eliminar') {
                      _confirmarEliminar(r);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Editar'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            if (r.cedula != null)
              _FilaDetalleRepartidor(
                  icono: Icons.fingerprint, texto: 'Cédula: ${r.cedula}'),
            if (r.telefono != null)
              _FilaDetalleRepartidor(
                  icono: Icons.phone_android,
                  texto: 'Teléfono: ${r.telefono}'),
            if (r.email != null)
              _FilaDetalleRepartidor(
                  icono: Icons.email_outlined, texto: 'Correo: ${r.email}'),
            _FilaDetalleRepartidor(
              icono: Icons.commute,
              texto: r.vehiculoTipo != null
                  ? 'Vehículo: ${r.vehiculoTipo} ${r.vehiculoMarca ?? ''} — placa ${r.vehiculoPlaca ?? 'N/D'}'
                  : 'Vehículo: ${r.vehiculo ?? 'sin registrar'}',
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaDetalleRepartidor extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _FilaDetalleRepartidor({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icono, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
