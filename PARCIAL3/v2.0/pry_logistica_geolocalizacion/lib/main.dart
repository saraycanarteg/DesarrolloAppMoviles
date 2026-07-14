import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'core/services/notificaciones_service.dart';
import 'core/theme/app_theme.dart';
import 'model/data/datasources/auth_remote_datasource.dart';
import 'model/data/datasources/database_remote_datasource.dart';
import 'model/data/datasources/geocodificacion_remote_datasource.dart';
import 'model/data/datasources/location_datasource.dart';
import 'model/data/datasources/ruta_remote_datasource.dart';
import 'model/data/repositories/auth_repository_impl.dart';
import 'model/data/repositories/geocodificacion_repository_impl.dart';
import 'model/data/repositories/pedido_repository_impl.dart';
import 'model/data/repositories/ruta_repository_impl.dart';
import 'model/data/repositories/ubicacion_repository_impl.dart';
import 'model/domain/usecases/auth/cambiar_password_usecase.dart';
import 'model/domain/usecases/auth/login_usecase.dart';
import 'model/domain/usecases/auth/registrar_repartidor_usecase.dart';
import 'model/domain/usecases/geocodificacion/buscar_direccion_usecase.dart';
import 'model/domain/usecases/geocodificacion/obtener_direccion_usecase.dart';
import 'model/domain/usecases/pedido/aceptar_pedido_usecase.dart';
import 'model/domain/usecases/pedido/asignar_repartidor_usecase.dart';
import 'model/domain/usecases/pedido/crear_pedido_usecase.dart';
import 'model/domain/usecases/pedido/observar_repartidores_usecase.dart';
import 'model/domain/usecases/pedido/iniciar_ruta_usecase.dart';
import 'model/domain/usecases/pedido/iniciar_ruta_cliente_usecase.dart';
import 'model/domain/usecases/pedido/marcar_entregado_usecase.dart';
import 'model/domain/usecases/pedido/marcar_recogido_usecase.dart';
import 'model/domain/usecases/pedido/observar_pedido_propuesto_usecase.dart';
import 'model/domain/usecases/pedido/observar_todos_los_pedidos_usecase.dart';
import 'model/domain/usecases/pedido/rechazar_pedido_usecase.dart';
import 'model/domain/usecases/repartidor/actualizar_repartidor_usecase.dart';
import 'model/domain/usecases/repartidor/eliminar_repartidor_usecase.dart';
import 'model/domain/usecases/tracking/calcular_ruta_directa_usecase.dart';
import 'model/domain/usecases/tracking/iniciar_tracking_usecase.dart';
import 'model/domain/usecases/tracking/observar_ubicacion_repartidor_usecase.dart';
import 'model/domain/usecases/tracking/obtener_ruta_usecase.dart';
import 'view/screens/splash_screen.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/gestion_repartidor_viewmodel.dart';
import 'viewmodel/mapa_viewmodel.dart';
import 'viewmodel/pedido_viewmodel.dart';
import 'viewmodel/registro_pedido_viewmodel.dart';
import 'viewmodel/repartidor_viewmodel.dart';
import 'viewmodel/tracking_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ===== Servicios =====
  // FCM + notificaciones locales (pedido propuesto, entrega confirmada)
  final notificacionesService = NotificacionesService();
  await notificacionesService.inicializar();

  // ===== Capa data =====
  final authDataSource = AuthRemoteDataSource(
    obtenerFcmToken: notificacionesService.obtenerTokenFcm,
  );
  final databaseDataSource = DatabaseRemoteDataSource();
  final locationDataSource = LocationDataSource();
  final rutaDataSource = RutaRemoteDataSource();
  final geocodificacionDataSource = GeocodificacionRemoteDataSource();

  final authRepository = AuthRepositoryImpl(authDataSource);
  final pedidoRepository = PedidoRepositoryImpl(databaseDataSource);
  final ubicacionRepository = UbicacionRepositoryImpl(
    locationDataSource,
    databaseDataSource,
  );
  final rutaRepository = RutaRepositoryImpl(rutaDataSource, databaseDataSource);
  final geocodificacionRepository = GeocodificacionRepositoryImpl(
    geocodificacionDataSource,
  );

  // ===== Casos de uso =====
  final loginUseCase = LoginUseCase(authRepository);
  final registrarRepartidorUseCase = RegistrarRepartidorUseCase(authRepository);
  final cambiarPasswordUseCase = CambiarPasswordUseCase(authRepository);
  final actualizarRepartidorUseCase = ActualizarRepartidorUseCase(
    pedidoRepository,
  );
  final eliminarRepartidorUseCase = EliminarRepartidorUseCase(pedidoRepository);

  final asignarRepartidorUseCase = AsignarRepartidorUseCase(pedidoRepository);
  final aceptarPedidoUseCase = AceptarPedidoUseCase(pedidoRepository);
  final rechazarPedidoUseCase = RechazarPedidoUseCase(pedidoRepository);
  final observarPedidoPropuestoUseCase = ObservarPedidoPropuestoUseCase(
    pedidoRepository,
  );
  final observarTodosLosPedidosUseCase = ObservarTodosLosPedidosUseCase(
    pedidoRepository,
  );
  final iniciarRutaUseCase = IniciarRutaUseCase(pedidoRepository);
  final marcarRecogidoUseCase = MarcarRecogidoUseCase(pedidoRepository);
  final iniciarRutaClienteUseCase = IniciarRutaClienteUseCase(pedidoRepository);
  final marcarEntregadoUseCase = MarcarEntregadoUseCase(pedidoRepository);
  final crearPedidoUseCase = CrearPedidoUseCase(pedidoRepository);
  final observarRepartidoresUseCase = ObservarRepartidoresUseCase(
    pedidoRepository,
  );

  final iniciarTrackingUseCase = IniciarTrackingUseCase(ubicacionRepository);
  final observarUbicacionRepartidorUseCase = ObservarUbicacionRepartidorUseCase(
    ubicacionRepository,
  );
  final obtenerRutaUseCase = ObtenerRutaUseCase(rutaRepository);
  final calcularRutaDirectaUseCase = CalcularRutaDirectaUseCase(rutaRepository);

  final buscarDireccionUseCase = BuscarDireccionUseCase(
    geocodificacionRepository,
  );
  final obtenerDireccionUseCase = ObtenerDireccionUseCase(
    geocodificacionRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(loginUseCase, cambiarPasswordUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => GestionRepartidorViewModel(
            registrarRepartidorUseCase,
            actualizarRepartidorUseCase,
            eliminarRepartidorUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PedidoViewModel(
            asignarRepartidorUseCase,
            observarTodosLosPedidosUseCase,
            observarRepartidoresUseCase,
            crearPedidoUseCase,
            notificaciones: notificacionesService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RepartidorViewModel(
            observarPedidoPropuestoUseCase,
            aceptarPedidoUseCase,
            rechazarPedidoUseCase,
            notificaciones: notificacionesService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TrackingViewModel(iniciarTrackingUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => MapaViewModel(
            obtenerRutaUseCase,
            calcularRutaDirectaUseCase,
            observarUbicacionRepartidorUseCase,
            observarTodosLosPedidosUseCase,
            iniciarRutaUseCase,
            marcarRecogidoUseCase,
            iniciarRutaClienteUseCase,
            marcarEntregadoUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistroPedidoViewModel(
            buscarDireccionUseCase,
            obtenerDireccionUseCase,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      // Español para los widgets de Material (p. ej. el selector de rango
      // de fechas del filtro de pedidos).
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
