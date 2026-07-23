import 'package:firebase_database/firebase_database.dart';
import '../../domain/models/mensaje.dart';

class ChatFirebaseService {
  final DatabaseReference _ref =
  FirebaseDatabase.instance.ref('chats/general');

  //  Enviar mensaje
  Future<void> enviarMensaje(Mensaje mensaje) async {
    await _ref.push().set(mensaje.toJson());
  }

  // Guardar token de FCM
  Future<void> guardarToken(String token) async {
    await FirebaseDatabase.instance
        .ref('tokens')
        .child(token.replaceAll(RegExp(r'[.#$\[\]]'), '_'))
        .set({
      'token': token,
      'lastUpdated': ServerValue.timestamp,
    });
  }

  //  Stream de mensajes en tiempo real
  Stream<List<Mensaje>> recibirMensajes() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      final mensajes = data.values
          .map((e) => Mensaje.fromJson(e))
          .toList();

      mensajes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return mensajes;
    });
  }
}
