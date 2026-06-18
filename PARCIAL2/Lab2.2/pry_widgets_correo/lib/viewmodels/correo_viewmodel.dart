import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../models/correo_model.dart';

class CorreoViewModel extends ChangeNotifier {
  // CONFIGURACIÓN OBLIGATORIA (google_sign_in 7.0+ en Android):
  // Ve a Google Cloud Console > Clientes y busca el cliente de tipo "Aplicación web" (Web application).
  // Copia el ID de cliente (ej. 12345678-abc.apps.googleusercontent.com) y pégalo aquí abajo:
  static const String serverClientId = '89112353847-hhsh4t28g0flmlrjtl7s3k35ljd8459h.apps.googleusercontent.com';

  // Lista en memoria de correos
  final List<Correo> _correos = [];
  String _searchQuery = '';

  GoogleSignInAccount? _usuarioActual;
  bool _esModoReal = false;
  bool _autenticando = false;
  String? _errorMsg;

  // Getters
  GoogleSignInAccount? get usuarioActual => _usuarioActual;
  bool get esModoReal => _esModoReal;
  bool get autenticando => _autenticando;
  String? get errorMsg => _errorMsg;

  CorreoViewModel() {
    _inicializarAutenticacion();
  }

  // Comprueba si ya había una sesión iniciada
  Future<void> _inicializarAutenticacion() async {
    _autenticando = true;
    notifyListeners();
    try {
      // Inicializar plugin (Requerido en google_sign_in 7.0+)
      if (serverClientId != 'PEGA_AQUI_TU_CLIENT_ID_WEB') {
        await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
      } else {
        await GoogleSignIn.instance.initialize();
      }

      // Escuchar cambios de usuario a través de los eventos de autenticación
      GoogleSignIn.instance.authenticationEvents.listen((event) async {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _usuarioActual = event.user;
          _esModoReal = true;
          _errorMsg = null;
          await cargarCorreosDesdeGmail();
        } else {
          _usuarioActual = null;
          _esModoReal = false;
          await _cargarCorreos();
        }
        notifyListeners();
      });

      // Intentar revivir sesión silenciosa previa
      await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (_usuarioActual == null) {
        await _cargarCorreos();
      }
    } catch (e) {
      debugPrint("Error al inicializar autenticación silenciosa: $e");
      await _cargarCorreos();
    } finally {
      _autenticando = false;
      notifyListeners();
    }
  }

  // Helper para obtener el cliente HTTP autenticado
  Future<dynamic> _obtenerClienteAutenticado() async {
    if (_usuarioActual == null) return null;
    try {
      final relevantScopes = [
        GmailApi.gmailReadonlyScope,
        GmailApi.gmailSendScope,
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ];
      final authClient = _usuarioActual!.authorizationClient;
      var authorization = await authClient.authorizationForScopes(relevantScopes);
      authorization ??= await authClient.authorizeScopes(relevantScopes);
      return authorization.authClient(scopes: relevantScopes);
    } catch (e) {
      debugPrint("Error al obtener cliente autenticado: $e");
      return null;
    }
  }

  // Iniciar sesión con Google
  Future<bool> iniciarSesionGoogle() async {
    if (serverClientId == 'PEGA_AQUI_TU_CLIENT_ID_WEB') {
      _errorMsg = "Por favor configura el 'serverClientId' en correo_viewmodel.dart con tu ID de cliente Web.";
      notifyListeners();
      return false;
    }
    _autenticando = true;
    _errorMsg = null;
    notifyListeners();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      if (account != null) {
        _usuarioActual = account;
        final relevantScopes = [
          GmailApi.gmailReadonlyScope,
          GmailApi.gmailSendScope,
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ];
        // Forzar la solicitud de scopes si no están autorizados
        final authClient = account.authorizationClient;
        var authorization = await authClient.authorizationForScopes(relevantScopes);
        authorization ??= await authClient.authorizeScopes(relevantScopes);

        _esModoReal = true;
        await cargarCorreosDesdeGmail();
        return true;
      }
    } catch (e) {
      debugPrint("Error al iniciar sesión: $e");
      _errorMsg = "Error al iniciar sesión: $e";
      _esModoReal = false;
      _usuarioActual = null;
      await _cargarCorreos();
    } finally {
      _autenticando = false;
      notifyListeners();
    }
    return false;
  }

  // Cerrar sesión
  Future<void> cerrarSesionGoogle() async {
    _autenticando = true;
    _errorMsg = null;
    notifyListeners();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
      _errorMsg = "Error al cerrar sesión: $e";
    } finally {
      _autenticando = false;
      notifyListeners();
    }
  }

  // Carga los correos guardados desde SharedPreferences, o carga los por defecto (Modo simulación)
  Future<void> _cargarCorreos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? correosJson = prefs.getStringList('lista_correos');

      if (correosJson != null && correosJson.isNotEmpty) {
        _correos.clear();
        for (var item in correosJson) {
          final Map<String, dynamic> map = json.decode(item) as Map<String, dynamic>;
          _correos.add(Correo.fromJson(map));
        }
      } else {
        _cargarCorreosPorDefecto();
        await _guardarCorreos();
      }
    } catch (e) {
      debugPrint("Error al cargar correos persistentes: $e");
      _cargarCorreosPorDefecto();
    }
    notifyListeners();
  }

  void _cargarCorreosPorDefecto() {
    _correos.clear();
    _correos.addAll([
      Correo(
        id: '1',
        remitente: 'Google Security',
        asunto: 'Nueva alerta de inicio de sesión',
        cuerpo: 'Se ha detectado un inicio de sesión en un dispositivo Windows nuevo en tu cuenta.',
        fecha: DateTime.now().subtract(const Duration(minutes: 5)),
        leido: false,
      ),
      Correo(
        id: '2',
        remitente: 'GitHub Support',
        asunto: '[GitHub] Tu contraseña ha sido cambiada',
        cuerpo: 'Hola, te escribimos para notificarte que la contraseña de tu cuenta de GitHub ha sido restablecida exitosamente.',
        fecha: DateTime.now().subtract(const Duration(hours: 1)),
        leido: false,
      ),
      Correo(
        id: '3',
        remitente: 'Netflix',
        asunto: 'Novedades para este fin de semana',
        cuerpo: '¡No te pierdas los nuevos estrenos! Ya están disponibles las nuevas temporadas de tus series favoritas.',
        fecha: DateTime.now().subtract(const Duration(hours: 4)),
        leido: true,
      ),
      Correo(
        id: '5',
        remitente: 'Spotify',
        asunto: 'Tu lista de reproducción semanal está lista',
        cuerpo: 'Hemos seleccionado 30 canciones nuevas especialmente para ti basadas en tus gustos musicales recientes. ¡Escúchalas ya!',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        leido: true,
      ),
    ]);
  }

  // Cargar correos desde la cuenta real de Gmail
  Future<void> cargarCorreosDesdeGmail() async {
    if (_usuarioActual == null) return;

    _autenticando = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final httpClient = await _obtenerClienteAutenticado();
      if (httpClient == null) {
        throw Exception("No se pudo obtener el cliente HTTP autenticado. Revisa permisos.");
      }

      final gmailApi = GmailApi(httpClient);
      // Listar últimos 15 correos de la bandeja de entrada
      final response = await gmailApi.users.messages.list(
        'me',
        maxResults: 15,
        q: 'label:INBOX',
      );

      final messages = response.messages;
      _correos.clear();

      if (messages != null && messages.isNotEmpty) {
        // Carga de detalles en paralelo para velocidad
        final detailedMessages = await Future.wait(
          messages.map((m) => gmailApi.users.messages.get('me', m.id!))
        );

        for (var msg in detailedMessages) {
          final headers = msg.payload?.headers;
          final remitente = _obtenerCabecera(headers, 'From');
          final asunto = _obtenerCabecera(headers, 'Subject');

          DateTime fecha = DateTime.now();
          if (msg.internalDate != null) {
            final ms = int.tryParse(msg.internalDate!);
            if (ms != null) {
              fecha = DateTime.fromMillisecondsSinceEpoch(ms);
            }
          }

          final esLeido = !(msg.labelIds?.contains('UNREAD') ?? false);
          final cuerpo = msg.snippet ?? '(Mensaje vacío)';

          _correos.add(Correo(
            id: msg.id ?? UniqueKey().toString(),
            remitente: remitente.isNotEmpty ? remitente : 'Desconocido',
            asunto: asunto.isNotEmpty ? asunto : '(Sin Asunto)',
            cuerpo: cuerpo,
            fecha: fecha,
            leido: esLeido,
          ));
        }
      }
    } catch (e) {
      debugPrint("Error al cargar correos desde Gmail: $e");
      _errorMsg = "Error al conectar con Gmail: $e";
      // Modo fallback automático si ocurre un error inesperado
      _esModoReal = false;
      await _cargarCorreos();
    } finally {
      _autenticando = false;
      notifyListeners();
    }
  }

  String _obtenerCabecera(List<MessagePartHeader>? headers, String nombre) {
    if (headers == null) return '';
    final h = headers.firstWhere(
      (element) => element.name?.toLowerCase() == nombre.toLowerCase(),
      orElse: () => MessagePartHeader(name: nombre, value: ''),
    );
    return h.value ?? '';
  }

  // Guarda la lista de correos actual en SharedPreferences (sólo en modo simulación)
  Future<void> _guardarCorreos() async {
    if (_esModoReal) return; // No guardamos correos reales localmente
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> correosJson = _correos.map((correo) {
        return json.encode(correo.toJson());
      }).toList();
      await prefs.setStringList('lista_correos', correosJson);
    } catch (e) {
      debugPrint("Error al guardar correos persistentes: $e");
    }
  }

  // Getter para obtener la cantidad de correos no leídos
  int get noLeidos => _correos.where((correo) => !correo.leido).length;

  // Getter para obtener los correos filtrados por la búsqueda
  List<Correo> get correosFiltrados {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_correos);
    }
    final query = _searchQuery.toLowerCase();
    return _correos.where((correo) {
      return correo.remitente.toLowerCase().contains(query) ||
          correo.asunto.toLowerCase().contains(query) ||
          correo.cuerpo.toLowerCase().contains(query);
    }).toList();
  }

  // Método para marcar todos los correos como leídos
  Future<void> marcarTodosLeidos() async {
    final unreadIds = _correos.where((c) => !c.leido).map((c) => c.id).toList();
    for (var correo in _correos) {
      correo.leido = true;
    }
    notifyListeners();

    if (_esModoReal) {
      try {
        final httpClient = await _obtenerClienteAutenticado();
        if (httpClient != null) {
          final gmailApi = GmailApi(httpClient);
          for (var id in unreadIds) {
            final request = ModifyMessageRequest()..removeLabelIds = ['UNREAD'];
            await gmailApi.users.messages.modify(request, 'me', id);
          }
        }
      } catch (e) {
        debugPrint("Error al marcar todos como leídos en Gmail: $e");
      }
    } else {
      await _guardarCorreos();
    }
  }

  // Método para marcar un correo específico como leído
  Future<void> marcarComoLeido(String id) async {
    final index = _correos.indexWhere((correo) => correo.id == id);
    if (index != -1 && !_correos[index].leido) {
      _correos[index].leido = true;
      notifyListeners();

      if (_esModoReal) {
        try {
          final httpClient = await _obtenerClienteAutenticado();
          if (httpClient != null) {
            final gmailApi = GmailApi(httpClient);
            final request = ModifyMessageRequest()..removeLabelIds = ['UNREAD'];
            await gmailApi.users.messages.modify(request, 'me', id);
          }
        } catch (e) {
          debugPrint("Error al marcar como leído en Gmail: $e");
        }
      } else {
        await _guardarCorreos();
      }
    }
  }

  // Método para establecer la consulta de búsqueda
  void establecerBusqueda(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Método para simular la recepción de un nuevo correo
  void recibirNuevoCorreo() {
    if (_esModoReal) return; // Deshabilitado en modo real

    final nuevosRemitentes = [
      'Duolingo',
      'Amazon Notificaciones',
      'Slack Team',
      'Platzi Support',
      'LinkedIn'
    ];
    final nuevosAsuntos = [
      '¡No pierdas tu racha de hoy!',
      'Tu pedido ha sido enviado y está en camino',
      'Nuevo mensaje de tu compañero en el canal general',
      'Tienes 5 cursos recomendados para esta semana',
      'Tu perfil ha sido visto por 15 personas esta semana'
    ];
    final nuevosCuerpos = [
      'Es hora de tu práctica diaria de 5 minutos. ¡Mantén encendido el búho!',
      '¡Buenas noticias! Tu paquete ya fue despachado y llegará hoy antes de las 8:00 PM.',
      'Hola, te han mencionado en el grupo de trabajo. Revisa los detalles de la entrega pendiente.',
      'Sigue aprendiendo. Te recomendamos revisar el nuevo curso de Flutter avanzado y Clean Architecture.',
      'Mira quiénes han visto tu perfil y descubre nuevas oportunidades de empleo en tu área.'
    ];

    final index = DateTime.now().millisecond % nuevosRemitentes.length;

    final nuevo = Correo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      remitente: nuevosRemitentes[index],
      asunto: nuevosAsuntos[index],
      cuerpo: nuevosCuerpos[index],
      fecha: DateTime.now(),
      leido: false,
    );

    _correos.insert(0, nuevo);
    _guardarCorreos();
    notifyListeners();
  }

  // Método para redactar y enviar un correo (real o simulado)
  Future<bool> redactarNuevoCorreo(String destinatario, String asunto, String cuerpo) async {
    if (_esModoReal) {
      try {
        final httpClient = await _obtenerClienteAutenticado();
        if (httpClient == null) {
          throw Exception("No se pudo obtener cliente autenticado.");
        }
        final gmailApi = GmailApi(httpClient);

        final emailContent =
            'To: $destinatario\r\n'
            'Subject: $asunto\r\n'
            'Content-Type: text/plain; charset=utf-8\r\n'
            'MIME-Version: 1.0\r\n\r\n'
            '$cuerpo';

        final encodedContent = base64Url
            .encode(utf8.encode(emailContent))
            .replaceAll('+', '-')
            .replaceAll('/', '_')
            .replaceAll('=', '');

        final messageToSend = Message()..raw = encodedContent;
        await gmailApi.users.messages.send(messageToSend, 'me');

        // Agregar localmente para feedback visual
        final nuevo = Correo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          remitente: 'Para: $destinatario',
          asunto: asunto.isNotEmpty ? asunto : '(Sin Asunto)',
          cuerpo: cuerpo.isNotEmpty ? cuerpo : '(Mensaje vacío)',
          fecha: DateTime.now(),
          leido: true,
        );
        _correos.insert(0, nuevo);
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint("Error al enviar correo: $e");
        _errorMsg = "Error al enviar: $e";
        notifyListeners();
        return false;
      }
    } else {
      final nuevo = Correo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        remitente: destinatario.isNotEmpty ? 'Para: $destinatario' : 'Para: (Sin destinatario)',
        asunto: asunto.isNotEmpty ? asunto : '(Sin Asunto)',
        cuerpo: cuerpo.isNotEmpty ? cuerpo : '(Mensaje vacío)',
        fecha: DateTime.now(),
        leido: true,
      );

      _correos.insert(0, nuevo);
      await _guardarCorreos();
      notifyListeners();
      return true;
    }
  }
}