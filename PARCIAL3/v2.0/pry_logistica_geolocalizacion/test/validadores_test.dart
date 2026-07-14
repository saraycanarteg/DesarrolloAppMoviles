// Pruebas de las validaciones de formularios (módulo de gestión de
// repartidores y login) y del parseo del modelo de repartidor extendido
// con cédula y datos del vehículo. Todo es Dart puro, sin Firebase.

import 'package:flutter_test/flutter_test.dart';
import 'package:Navora/core/utils/validadores.dart';
import 'package:Navora/model/data/models/repartidor_model.dart';

void main() {
  group('Validadores.cedulaEcuatoriana', () {
    test('acepta cédulas válidas (dígito verificador correcto)', () {
      expect(Validadores.cedulaEcuatoriana('1712345675'), isNull);
      expect(Validadores.cedulaEcuatoriana('1710034065'), isNull);
    });

    test('rechaza dígito verificador incorrecto', () {
      expect(Validadores.cedulaEcuatoriana('1712345678'), isNotNull);
    });

    test('rechaza longitud distinta de 10 dígitos', () {
      expect(Validadores.cedulaEcuatoriana('123456789'), isNotNull);
      expect(Validadores.cedulaEcuatoriana('12345678901'), isNotNull);
      expect(Validadores.cedulaEcuatoriana('17123A5675'), isNotNull);
    });

    test('rechaza código de provincia inválido', () {
      expect(Validadores.cedulaEcuatoriana('0012345675'), isNotNull);
      expect(Validadores.cedulaEcuatoriana('2512345675'), isNotNull);
    });

    test('rechaza tercer dígito mayor a 5 (no persona natural)', () {
      expect(Validadores.cedulaEcuatoriana('1792345675'), isNotNull);
    });

    test('rechaza vacío o nulo', () {
      expect(Validadores.cedulaEcuatoriana(''), isNotNull);
      expect(Validadores.cedulaEcuatoriana(null), isNotNull);
    });
  });

  group('Validadores.placaEcuatoriana', () {
    test('acepta placas de vehículo con y sin guion', () {
      expect(Validadores.placaEcuatoriana('ABC-1234'), isNull);
      expect(Validadores.placaEcuatoriana('PBA123'), isNull);
      expect(Validadores.placaEcuatoriana('abc-1234'), isNull); // normaliza mayúsculas
    });

    test('acepta placas de moto', () {
      expect(Validadores.placaEcuatoriana('AB123C'), isNull);
    });

    test('rechaza formatos inválidos', () {
      expect(Validadores.placaEcuatoriana('1234-ABC'), isNotNull);
      expect(Validadores.placaEcuatoriana('AB-12'), isNotNull);
      expect(Validadores.placaEcuatoriana(''), isNotNull);
    });
  });

  group('Validadores.telefonoEcuatoriano', () {
    test('acepta celular nacional e internacional', () {
      expect(Validadores.telefonoEcuatoriano('0991234567'), isNull);
      expect(Validadores.telefonoEcuatoriano('+593991234567'), isNull);
    });

    test('rechaza formatos inválidos', () {
      expect(Validadores.telefonoEcuatoriano('12345'), isNotNull);
      expect(Validadores.telefonoEcuatoriano('099123456'), isNotNull);
      expect(Validadores.telefonoEcuatoriano(''), isNotNull);
    });
  });

  group('Validadores.email y password', () {
    test('email válido e inválido', () {
      expect(Validadores.email('admin@espe.edu.ec'), isNull);
      expect(Validadores.email('sin-arroba'), isNotNull);
      expect(Validadores.email(''), isNotNull);
    });

    test('password mínimo 6 caracteres', () {
      expect(Validadores.password('123456'), isNull);
      expect(Validadores.password('12345'), isNotNull);
    });
  });

  group('RepartidorModel.fromMap con datos de cédula y vehículo', () {
    test('parsea los campos nuevos', () {
      final repartidor = RepartidorModel.fromMap({
        'nombre': 'Andrés Cedeño',
        'disponible': true,
        'cedula': '1712345675',
        'telefono': '+593912345678',
        'vehiculo': 'Moto ABC-123',
        'vehiculoTipo': 'Moto',
        'vehiculoMarca': 'Yamaha FZ',
        'vehiculoPlaca': 'ABC-123',
      }, 'uid1');

      expect(repartidor.cedula, '1712345675');
      expect(repartidor.vehiculoTipo, 'Moto');
      expect(repartidor.vehiculoPlaca, 'ABC-123');
      expect(repartidor.disponible, isTrue);
    });

    test('tolera registros antiguos sin los campos nuevos', () {
      final repartidor = RepartidorModel.fromMap({
        'nombre': 'Viejo',
        'disponible': false,
        'vehiculo': 'Moto XYZ-987',
      }, 'uid2');

      expect(repartidor.cedula, isNull);
      expect(repartidor.vehiculoTipo, isNull);
      expect(repartidor.vehiculo, 'Moto XYZ-987');
    });
  });
}
