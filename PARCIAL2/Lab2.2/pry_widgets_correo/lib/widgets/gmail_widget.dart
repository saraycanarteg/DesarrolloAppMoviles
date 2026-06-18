import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/correo_viewmodel.dart';
import '../models/correo_model.dart';

class GmailWidget extends StatefulWidget {
  final VoidCallback? onBuscarTap;
  final VoidCallback? onRedactarTap;
  final VoidCallback? onNoLeidosTap;

  const GmailWidget({
    super.key,
    this.onBuscarTap,
    this.onRedactarTap,
    this.onNoLeidosTap,
  });

  @override
  State<GmailWidget> createState() => _GmailWidgetState();
}

class _GmailWidgetState extends State<GmailWidget> {
  final TextEditingController _searchController = TextEditingController();

  // Colores aleatorios predefinidos para los avatares circulares
  final List<Color> _avatarColors = [
    Colors.red[400]!,
    Colors.blue[400]!,
    Colors.green[400]!,
    Colors.orange[400]!,
    Colors.purple[400]!,
    Colors.teal[400]!,
    Colors.pink[400]!,
    Colors.indigo[400]!,
  ];

  Color _getAvatarColor(String text) {
    if (text.isEmpty) return Colors.grey;
    final int charCode = text.codeUnitAt(0);
    return _avatarColors[charCode % _avatarColors.length];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CorreoViewModel>(context);
    final correos = vm.correosFiltrados;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Barra de Búsqueda Superior Estilo Gmail
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey[300]!, width: 0.5),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black54),
                    onPressed: widget.onBuscarTap, // Mapea al buscar tap para desplegar menú/info
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        vm.establecerBusqueda(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Buscar en el correo',
                        hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        vm.establecerBusqueda('');
                      },
                    ),
                  GestureDetector(
                    onTap: () {
                      _mostrarDialogoPerfil(context, vm);
                    },
                    child: vm.usuarioActual != null
                        ? CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.blue[600],
                            backgroundImage: vm.usuarioActual!.photoUrl != null
                                ? NetworkImage(vm.usuarioActual!.photoUrl!)
                                : null,
                            child: vm.usuarioActual!.photoUrl == null
                                ? Text(
                                    vm.usuarioActual!.displayName?.isNotEmpty ?? false
                                        ? vm.usuarioActual!.displayName![0].toUpperCase()
                                        : 'G',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          )
                        : const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.login,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // 2. Banner de Información de No Leídos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Buzón',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: vm.noLeidos > 0 ? Colors.red[50] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${vm.noLeidos} sin leer',
                          style: TextStyle(
                            color: vm.noLeidos > 0 ? Colors.red[700] : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (vm.noLeidos > 0)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: widget.onNoLeidosTap,
                      child: Text(
                        'Marcar leídos',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 12, thickness: 0.5),

            // 3. Listado de Correos
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: correos.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail_outline, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No hay correos que coincidan',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: correos.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 70, thickness: 0.5),
                      itemBuilder: (context, index) {
                        final correo = correos[index];
                        final avatarColor = _getAvatarColor(correo.remitente);
                        final inicial = correo.remitente.isNotEmpty ? correo.remitente[0].toUpperCase() : '?';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: avatarColor,
                            child: Text(
                              inicial,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  correo.remitente,
                                  style: TextStyle(
                                    fontWeight: correo.leido ? FontWeight.normal : FontWeight.bold,
                                    color: correo.leido ? Colors.grey[700] : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatearFecha(correo.fecha),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: correo.leido ? FontWeight.normal : FontWeight.bold,
                                  color: correo.leido ? Colors.grey[500] : Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        correo.asunto,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: correo.leido ? FontWeight.normal : FontWeight.bold,
                                          color: correo.leido ? Colors.grey[600] : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        correo.cuerpo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!correo.leido)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8, top: 8),
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          onTap: () {
                            // Marcar como leído
                            vm.marcarComoLeido(correo.id);
                            // Mostrar detalle
                            _mostrarDetalleCorreo(context, correo);
                          },
                        );
                      },
                    ),
            ),

            // 4. Barra de Acciones del Widget (Redactar y Status)
            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: widget.onRedactarTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text(
                      'Redactar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Text(
                    vm.esModoReal ? 'Gmail Real' : 'Widget de Simulación',
                    style: TextStyle(
                      fontSize: 12,
                      color: vm.esModoReal ? Colors.green[700] : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontWeight: vm.esModoReal ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para formatear fechas de manera amigable
  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    if (fecha.year == ahora.year && fecha.month == ahora.month && fecha.day == ahora.day) {
      final minutos = fecha.minute.toString().padLeft(2, '0');
      return '${fecha.hour}:$minutos';
    }
    return '${fecha.day}/${fecha.month}';
  }

  // Muestra una ventana modal con el correo completo
  void _mostrarDetalleCorreo(BuildContext context, Correo correo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.mail, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Detalle del Correo',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 18,
                      child: Text(
                        correo.remitente.isNotEmpty ? correo.remitente[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            correo.remitente,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Para: mí',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatearFechaCompleta(correo.fecha),
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  correo.asunto,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  correo.cuerpo,
                  style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _formatearFechaCompleta(DateTime fecha) {
    final minutos = fecha.minute.toString().padLeft(2, '0');
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:$minutos';
  }

  void _mostrarDialogoPerfil(BuildContext context, CorreoViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cuenta de Google',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              if (vm.usuarioActual != null) ...[
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue[600],
                  backgroundImage: vm.usuarioActual!.photoUrl != null
                      ? NetworkImage(vm.usuarioActual!.photoUrl!)
                      : null,
                  child: vm.usuarioActual!.photoUrl == null
                      ? Text(
                          vm.usuarioActual!.displayName?.isNotEmpty ?? false
                              ? vm.usuarioActual!.displayName![0].toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  vm.usuarioActual!.displayName ?? 'Usuario de Google',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  vm.usuarioActual!.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!, width: 0.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Modo Gmail Real Activo',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[200]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    onPressed: () async {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cerrando sesión de Google...')),
                      );
                      await vm.cerrarSesionGoogle();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesión cerrada. Regresando a modo simulación.')),
                        );
                      }
                    },
                  ),
                ),
              ] else ...[
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person_outline, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Modo Simulación',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conecta tu cuenta para ver tus correos reales.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),
                vm.autenticando
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.login),
                          label: const Text('Iniciar Sesión con Google'),
                          onPressed: () async {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Iniciando sesión con Google...')),
                            );
                            final exito = await vm.iniciarSesionGoogle();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              if (exito) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sesión iniciada con éxito. Cargando correos...'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(vm.errorMsg ?? 'El inicio de sesión falló o fue cancelado.'),
                                    backgroundColor: Colors.red[700],
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
              ],
            ],
          ),
        );
      },
    );
  }
}
