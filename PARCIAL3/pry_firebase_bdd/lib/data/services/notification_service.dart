import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart'; // Importar el servicio para guardar el token

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _canalMensajes =
      AndroidNotificationChannel(
    'chat_messages',
    'Mensajes de chat',
    description: 'Notificaciones de nuevos mensajes en el chat',
    importance: Importance.high,
  );

  // Pasar el servicio de Firebase como argumento
  Future<void> initialize(ChatFirebaseService firebaseService) async {
    // Solicitar permisos (incluye el permiso de notificaciones en Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    await _initLocalNotifications();

    // Obtener el token del dispositivo
    String? token = await _fcm.getToken();

    if (token != null) {
      print("FCM Token: $token");
      // GUARDAR EL TOKEN EN LA BDD
      await firebaseService.guardarToken(token);
    }

    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        print('Message: ${message.notification?.title}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(settings: initSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_canalMensajes);
  }

  // Muestra una notificación local cuando llega un mensaje nuevo de otro usuario
  Future<void> mostrarNotificacionMensaje({
    required String autor,
    required String texto,
  }) async {
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: autor,
      body: texto,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _canalMensajes.id,
          _canalMensajes.name,
          channelDescription: _canalMensajes.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
