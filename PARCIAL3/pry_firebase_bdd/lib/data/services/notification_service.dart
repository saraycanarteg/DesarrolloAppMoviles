import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_service.dart'; // Importar el servicio para guardar el token

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Pasar el servicio de Firebase como argumento
  Future<void> initialize(ChatFirebaseService firebaseService) async {
    // Solicitar permisos
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
}