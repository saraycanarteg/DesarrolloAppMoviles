import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio de notificaciones del proyecto (módulo de Saray):
///
///  - Registra el dispositivo en Firebase Cloud Messaging (FCM) y expone el
///    token, que se guarda en `usuarios/{uid}/fcmToken` al iniciar sesión.
///    Con ese token se pueden enviar notificaciones push desde la consola de
///    Firebase o desde un backend.
///  - Muestra notificaciones locales en el dispositivo ante los eventos del
///    negocio observados en tiempo real sobre la RTDB: pedido propuesto al
///    repartidor y entrega confirmada (lado administrador).
class NotificacionesService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _inicializado = false;
  int _siguienteId = 0;

  /// FCM y las notificaciones locales solo están implementados en móvil.
  bool get _soportado =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> inicializar() async {
    if (!_soportado || _inicializado) return;

    try {
      // Permiso de notificaciones (iOS y Android 13+)
      await FirebaseMessaging.instance.requestPermission();

      const configuracion = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings: configuracion);
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Los push de FCM no se muestran solos con la app en primer plano:
      // los reenviamos como notificación local.
      FirebaseMessaging.onMessage.listen((RemoteMessage mensaje) {
        final notificacion = mensaje.notification;
        if (notificacion != null) {
          mostrar(
            titulo: notificacion.title ?? 'Navora',
            cuerpo: notificacion.body ?? '',
          );
        }
      });

      _inicializado = true;
    } catch (e) {
      debugPrint('⚠️ No se pudo inicializar el servicio de notificaciones: $e');
    }
  }

  /// Token FCM del dispositivo (null si la plataforma no lo soporta o falla).
  Future<String?> obtenerTokenFcm() async {
    if (!_soportado) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('⚠️ No se pudo obtener el token FCM: $e');
      return null;
    }
  }

  /// Muestra una notificación en la bandeja del sistema.
  Future<void> mostrar({required String titulo, required String cuerpo}) async {
    if (!_soportado || !_inicializado) return;

    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        'logistica_eventos',
        'Eventos de pedidos',
        channelDescription:
            'Avisos de pedidos propuestos, cambios de estado y entregas confirmadas',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.show(
        id: _siguienteId++,
        title: titulo,
        body: cuerpo,
        notificationDetails: detalles,
      );
    } catch (e) {
      debugPrint('⚠️ No se pudo mostrar la notificación: $e');
    }
  }
}
