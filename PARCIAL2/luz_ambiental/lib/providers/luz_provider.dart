import 'dart:async';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';
import '../models/luz.dart';

class LuzProvider extends ChangeNotifier {
  Luz? _luzActual;
  bool _monitoreando = false;
  StreamSubscription<int>? _suscripcion;

  Luz? get luzActual => _luzActual;
  bool get monitoreando => _monitoreando;

  Future<void> iniciarMonitoreo() async {
    final bool disponible = await LightSensor.hasSensor();
    if (!disponible) return;

    _monitoreando = true;
    notifyListeners();

    _suscripcion = LightSensor.luxStream().listen((int lux) {
      _luzActual = Luz.fromLux(lux);
      notifyListeners();
    });
  }

  Future<bool> sensorDisponible() async {
    return await LightSensor.hasSensor();
  }

  void detenerMonitoreo() {
    _suscripcion?.cancel();
    _suscripcion = null;
    _monitoreando = false;
    notifyListeners();
  }

  @override
  void dispose() {
    detenerMonitoreo();
    super.dispose();
  }
}