import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/notification_service.dart';
import '../../domain/models/mensaje.dart';

final firebaseServiceProvider =
Provider<ChatFirebaseService>((ref) => ChatFirebaseService());

// Instancia real sobreescrita en main.dart (ya inicializada con permisos y token)
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

// Usuario fijo por build: se define al ejecutar la app, por ejemplo:
//   flutter run --dart-define=USUARIO=Usuario1   (teléfono físico)
//   flutter run --dart-define=USUARIO=Usuario2   (emulador)
final currentUserProvider = Provider<String>((ref) {
  return const String.fromEnvironment('USUARIO', defaultValue: 'Usuario1');
});

final mensajesProvider = StreamProvider<List<Mensaje>>((ref) {
  final service = ref.read(firebaseServiceProvider);
  return service.recibirMensajes();
});
