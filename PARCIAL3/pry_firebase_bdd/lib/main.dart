import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'presentation/views/chat_view.dart';
import 'data/services/notification_service.dart';
import 'data/services/firebase_service.dart';

// Función para manejar mensajes en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Instanciar el servicio de Firebase
  final firebaseService = ChatFirebaseService();

  // 2. Inicializar notificaciones pasando el servicio para guardar el token
  final notificationService = NotificationService();
  await notificationService.initialize(firebaseService);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Firebase',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ChatView(),
    );
  }
}
