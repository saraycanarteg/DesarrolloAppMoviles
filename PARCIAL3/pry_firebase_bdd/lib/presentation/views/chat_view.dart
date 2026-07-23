import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../../domain/models/mensaje.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  late TextEditingController controller;
  final String usuario = "UsuarioDemo";

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void enviar() {
    final texto = controller.text.trim();
    if (texto.isEmpty) return;

    ref.read(firebaseServiceProvider).enviarMensaje(
          Mensaje(
            texto: texto,
            autor: usuario,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mensajesAsync = ref.watch(mensajesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat en Tiempo Real'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: mensajesAsync.when(
              data: (mensajes) => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: mensajes.length,
                itemBuilder: (_, i) {
                  final m = mensajes[i];
                  final esMio = m.autor == usuario;

                  return Align(
                    alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: esMio ? Colors.blueAccent : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.texto,
                            style: TextStyle(
                              color: esMio ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.autor,
                            style: TextStyle(
                              fontSize: 11,
                              color: esMio ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onSubmitted: (_) => enviar(),
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      final bool isNotEmpty = value.text.trim().isNotEmpty;
                      return CircleAvatar(
                        backgroundColor: isNotEmpty ? Colors.blue : Colors.grey,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: isNotEmpty ? enviar : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
