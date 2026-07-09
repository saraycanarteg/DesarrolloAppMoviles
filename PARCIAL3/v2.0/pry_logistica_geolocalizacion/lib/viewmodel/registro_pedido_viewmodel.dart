import 'package:flutter/foundation.dart';
import '../core/utils/geo_utils.dart';
import '../model/domain/entities/direccion_entity.dart';
import '../model/domain/usecases/geocodificacion/buscar_direccion_usecase.dart';
import '../model/domain/usecases/geocodificacion/obtener_direccion_usecase.dart';

enum CampoUbicacion { origen, destino }

/// Sincroniza el mapa y los campos de texto del formulario de pedidos:
/// - Tocar el mapa → geocodificación inversa (Nominatim) para llenar el campo.
/// - Escribir la dirección → búsqueda geocodificada para posicionar el marcador.
/// En ambos sentidos valida que la ubicación esté dentro de Ecuador.
class RegistroPedidoViewModel extends ChangeNotifier {
  final BuscarDireccionUseCase _buscarDireccionUseCase;
  final ObtenerDireccionUseCase _obtenerDireccionUseCase;

  RegistroPedidoViewModel(
    this._buscarDireccionUseCase,
    this._obtenerDireccionUseCase,
  );

  DireccionEntity? _origen;
  DireccionEntity? get origen => _origen;

  DireccionEntity? _destino;
  DireccionEntity? get destino => _destino;

  bool _procesando = false;
  bool get procesando => _procesando;

  String? _errorUbicacion;
  String? get errorUbicacion => _errorUbicacion;

  /// Punto tocado en el mapa: valida país y obtiene la dirección legible.
  /// Devuelve la dirección confirmada, o null si el punto es inválido.
  Future<DireccionEntity?> seleccionarPunto(
      CampoUbicacion campo, double lat, double lng) async {
    _errorUbicacion = null;

    // Pre-filtro geométrico sin red: descarta de inmediato puntos fuera del país.
    if (!GeoUtils.dentroDeEcuador(lat, lng)) {
      _errorUbicacion =
          'La ubicación seleccionada está fuera de Ecuador. Elige un punto dentro del país.';
      notifyListeners();
      return null;
    }

    _procesando = true;
    notifyListeners();

    try {
      final direccion = await _obtenerDireccionUseCase(lat, lng);

      if (direccion == null) {
        _errorUbicacion =
            'El punto seleccionado no corresponde a una dirección válida en el mapa.';
        return null;
      }
      if (!direccion.esEcuador) {
        _errorUbicacion =
            'La ubicación seleccionada está fuera de Ecuador. Elige un punto dentro del país.';
        return null;
      }

      // Conservamos las coordenadas exactas del toque (no las del centro
      // de la calle/manzana que devuelve Nominatim).
      final confirmada = DireccionEntity(
        descripcion: direccion.descripcion,
        lat: lat,
        lng: lng,
        codigoPais: direccion.codigoPais,
      );
      _asignar(campo, confirmada);
      return confirmada;
    } catch (_) {
      // Sin conexión con Nominatim: el punto ya pasó el filtro geométrico,
      // así que lo aceptamos con una descripción genérica de coordenadas.
      final confirmada = DireccionEntity(
        descripcion:
            'Punto (${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})',
        lat: lat,
        lng: lng,
        codigoPais: 'ec',
      );
      _asignar(campo, confirmada);
      return confirmada;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  /// Dirección escrita a mano: verifica que exista en el mapa (dentro de
  /// Ecuador) y devuelve sus coordenadas para posicionar el marcador.
  Future<DireccionEntity?> buscarDireccion(
      CampoUbicacion campo, String texto) async {
    _errorUbicacion = null;

    final consulta = texto.trim();
    if (consulta.isEmpty) {
      _errorUbicacion = 'Escribe una dirección para buscarla en el mapa.';
      notifyListeners();
      return null;
    }

    _procesando = true;
    notifyListeners();

    try {
      final direccion = await _buscarDireccionUseCase(consulta);

      if (direccion == null) {
        _errorUbicacion =
            'No se encontró "$consulta" en el mapa de Ecuador. Verifica la dirección.';
        return null;
      }
      // Doble validación: la búsqueda ya está restringida a Ecuador
      // (countrycodes=ec), pero confirmamos país y territorio.
      if (!direccion.esEcuador ||
          !GeoUtils.dentroDeEcuador(direccion.lat, direccion.lng)) {
        _errorUbicacion = 'La dirección encontrada está fuera de Ecuador.';
        return null;
      }

      _asignar(campo, direccion);
      return direccion;
    } catch (e) {
      _errorUbicacion = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  void _asignar(CampoUbicacion campo, DireccionEntity direccion) {
    if (campo == CampoUbicacion.origen) {
      _origen = direccion;
    } else {
      _destino = direccion;
    }
  }

  /// Reinicia el estado al abrir el formulario (el ViewModel es global).
  void limpiar() {
    _origen = null;
    _destino = null;
    _errorUbicacion = null;
    _procesando = false;
  }
}
