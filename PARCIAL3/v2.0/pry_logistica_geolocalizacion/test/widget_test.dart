// Pruebas unitarias del núcleo del módulo de geolocalización y del dominio.
//
// Se prueban las piezas puras (sin Firebase ni GPS real):
//  - Fórmula de Haversine (asignación por cercanía)
//  - Decodificación de polylines (formato Google/OSRM)
//  - Mapeo de estados del pedido
//  - Parseo de modelos desde mapas de Firebase

import 'package:flutter_test/flutter_test.dart';
import 'package:pry_logistica_geolocalizacion/core/utils/geo_utils.dart';
import 'package:pry_logistica_geolocalizacion/model/data/models/direccion_model.dart';
import 'package:pry_logistica_geolocalizacion/model/data/models/ruta_model.dart';
import 'package:pry_logistica_geolocalizacion/model/data/models/ubicacion_model.dart';
import 'package:pry_logistica_geolocalizacion/model/domain/entities/pedido_entity.dart';

void main() {
  group('GeoUtils.calcularDistanciaHaversine', () {
    test('distancia de un punto a sí mismo es 0', () {
      expect(GeoUtils.calcularDistanciaHaversine(-0.18, -78.46, -0.18, -78.46), 0);
    });

    test('distancia Quito centro → Mitad del Mundo ≈ 25 km', () {
      // Plaza Grande (Quito) → Ciudad Mitad del Mundo
      final distancia = GeoUtils.calcularDistanciaHaversine(
        -0.2202, -78.5123, // Plaza Grande
        -0.0022, -78.4558, // Mitad del Mundo
      );
      expect(distancia, closeTo(25, 5)); // en línea recta ~24-25 km
    });

    test('elige correctamente al repartidor más cercano', () {
      const latOrigen = -0.180653, lngOrigen = -78.467834;
      final distCerca = GeoUtils.calcularDistanciaHaversine(latOrigen, lngOrigen, -0.1810, -78.4680);
      final distLejos = GeoUtils.calcularDistanciaHaversine(latOrigen, lngOrigen, -0.2500, -78.5200);
      expect(distCerca, lessThan(distLejos));
    });
  });

  group('GeoUtils.decodificarPolyline', () {
    test('decodifica el ejemplo oficial del algoritmo de Google', () {
      final puntos = GeoUtils.decodificarPolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');

      expect(puntos.length, 3);
      expect(puntos[0][0], closeTo(38.5, 0.00001));
      expect(puntos[0][1], closeTo(-120.2, 0.00001));
      expect(puntos[1][0], closeTo(40.7, 0.00001));
      expect(puntos[1][1], closeTo(-120.95, 0.00001));
      expect(puntos[2][0], closeTo(43.252, 0.00001));
      expect(puntos[2][1], closeTo(-126.453, 0.00001));
    });

    test('polyline vacío devuelve lista vacía', () {
      expect(GeoUtils.decodificarPolyline(''), isEmpty);
    });
  });

  group('EstadoPedido: mapeo dominio ↔ Firebase', () {
    test('ida y vuelta de todos los estados', () {
      for (final estado in EstadoPedido.values) {
        final texto = PedidoEntity.estadoToString(estado);
        expect(PedidoEntity.stringToEstado(texto), estado);
      }
    });

    test('estado desconocido lanza error', () {
      expect(() => PedidoEntity.stringToEstado('volando'), throwsArgumentError);
    });

    test('alias legado en_ruta se interpreta como en ruta a cliente', () {
      expect(PedidoEntity.stringToEstado('en_ruta'), EstadoPedido.enRutaACliente);
    });

    test('los estados nuevos del ciclo de entrega existen y persisten en snake_case', () {
      expect(PedidoEntity.estadoToString(EstadoPedido.enRutaATienda), 'en_ruta_a_tienda');
      expect(PedidoEntity.estadoToString(EstadoPedido.recogido), 'recogido');
      expect(PedidoEntity.estadoToString(EstadoPedido.enRutaACliente), 'en_ruta_a_cliente');
    });
  });

  group('GeoUtils.dentroDeEcuador', () {
    test('acepta puntos dentro del país', () {
      expect(GeoUtils.dentroDeEcuador(-0.19, -78.48), isTrue); // Quito
      expect(GeoUtils.dentroDeEcuador(-2.19, -79.88), isTrue); // Guayaquil
      expect(GeoUtils.dentroDeEcuador(-0.74, -90.31), isTrue); // Galápagos (Pto. Ayora)
    });

    test('rechaza puntos fuera del país', () {
      expect(GeoUtils.dentroDeEcuador(4.71, -74.07), isFalse); // Bogotá
      expect(GeoUtils.dentroDeEcuador(-12.05, -77.04), isFalse); // Lima
      expect(GeoUtils.dentroDeEcuador(40.42, -3.70), isFalse); // Madrid
      expect(GeoUtils.dentroDeEcuador(-0.19, -85.0), isFalse); // mar abierto
    });
  });

  group('Modelos desde mapas de Firebase', () {
    test('RutaModel.fromMap parsea distancia y duración numéricas', () {
      final ruta = RutaModel.fromMap({
        'id': 'r1',
        'pedidoId': 'p1',
        'repartidorId': 'rep1',
        'polylineCodificado': 'abc',
        'distanciaKm': 5, // Firebase puede devolver int
        'duracionMin': 15.5,
      });

      expect(ruta.distanciaKm, 5.0);
      expect(ruta.duracionMin, 15.5);
      expect(ruta.pedidoId, 'p1');
    });

    test('UbicacionModel.fromMap tolera campos opcionales ausentes', () {
      final ubicacion = UbicacionModel.fromMap({
        'repartidorId': 'rep1',
        'lat': -0.18,
        'lng': -78.46,
        'timestamp': 1000,
      });

      expect(ubicacion.heading, isNull);
      expect(ubicacion.speed, isNull);
      expect(ubicacion.lat, -0.18);
    });

    test('DireccionModel.fromNominatim parsea coordenadas y país', () {
      final direccion = DireccionModel.fromNominatim({
        'display_name': 'Av. Amazonas, Quito, Pichincha, Ecuador',
        'lat': '-0.1900',
        'lon': '-78.4850',
        'address': {'country_code': 'ec'},
      });

      expect(direccion.descripcion, contains('Quito'));
      expect(direccion.lat, closeTo(-0.19, 0.0001));
      expect(direccion.lng, closeTo(-78.485, 0.0001));
      expect(direccion.esEcuador, isTrue);
    });

    test('DireccionModel.fromNominatim sin address no es Ecuador', () {
      final direccion = DireccionModel.fromNominatim({
        'display_name': 'Punto sin país',
        'lat': '10.0',
        'lon': '10.0',
      });

      expect(direccion.codigoPais, isNull);
      expect(direccion.esEcuador, isFalse);
    });
  });
}
