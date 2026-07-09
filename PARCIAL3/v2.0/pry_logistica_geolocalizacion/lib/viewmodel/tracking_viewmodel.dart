import 'dart:async';
import 'package:flutter/foundation.dart';
import '../model/domain/entities/ubicacion_entity.dart';
import '../model/domain/usecases/tracking/iniciar_tracking_usecase.dart';

enum TrackingState { inactivo, iniciando, activo, error }

/// Gestiona el ciclo de vida del tracking GPS del repartidor:
/// escucha el hardware de ubicación y publica cada posición en Firebase RTDB.
class TrackingViewModel extends ChangeNotifier {
  final IniciarTrackingUseCase _iniciarTrackingUseCase;

  TrackingViewModel(this._iniciarTrackingUseCase);

  StreamSubscription<UbicacionEntity>? _trackingSubscription;
  String? _repartidorId;

  TrackingState _state = TrackingState.inactivo;
  TrackingState get state => _state;

  UbicacionEntity? _ultimaUbicacion;
  UbicacionEntity? get ultimaUbicacion => _ultimaUbicacion;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get activo => _state == TrackingState.activo;

  Future<void> iniciar(String repartidorId) async {
    // Evitar doble suscripción si ya estamos rastreando al mismo repartidor
    if (_repartidorId == repartidorId &&
        (_state == TrackingState.activo || _state == TrackingState.iniciando)) {
      return;
    }

    await _trackingSubscription?.cancel();
    _repartidorId = repartidorId;
    _state = TrackingState.iniciando;
    _errorMessage = null;
    notifyListeners();

    _trackingSubscription = _iniciarTrackingUseCase(repartidorId).listen(
      (ubicacion) {
        _ultimaUbicacion = ubicacion;
        _state = TrackingState.activo;
        notifyListeners();
      },
      onError: (e) {
        _state = TrackingState.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        notifyListeners();
      },
    );
  }

  Future<void> detener() async {
    await _trackingSubscription?.cancel();
    _trackingSubscription = null;
    _repartidorId = null;
    _state = TrackingState.inactivo;
    notifyListeners();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    super.dispose();
  }
}
