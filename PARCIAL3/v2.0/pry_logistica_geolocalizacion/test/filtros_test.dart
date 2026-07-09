// Pruebas de los filtros del panel de administrador (funciones puras,
// sin Firebase): búsqueda de repartidores por nombre/cédula con filtros
// de vehículo y disponibilidad, y búsqueda de pedidos por cliente o
// repartidor con filtros de estado y rango de fechas.

import 'package:flutter_test/flutter_test.dart';
import 'package:pry_logistica_geolocalizacion/core/utils/filtros.dart';
import 'package:pry_logistica_geolocalizacion/model/domain/entities/pedido_entity.dart';
import 'package:pry_logistica_geolocalizacion/model/domain/entities/repartidor_entity.dart';

RepartidorEntity repartidor({
  required String uid,
  required String nombre,
  String? cedula,
  String? vehiculoTipo,
  bool disponible = true,
}) {
  return RepartidorEntity(
    uid: uid,
    nombre: nombre,
    disponible: disponible,
    cedula: cedula,
    vehiculoTipo: vehiculoTipo,
  );
}

PedidoEntity pedido({
  required String id,
  required String clienteNombre,
  String? repartidorNombre,
  EstadoPedido estado = EstadoPedido.pendiente,
  required DateTime creadoEn,
}) {
  return PedidoEntity(
    id: id,
    clienteNombre: clienteNombre,
    direccionOrigen: 'Origen',
    latOrigen: 0,
    lngOrigen: 0,
    direccionDestino: 'Destino',
    latDestino: 0,
    lngDestino: 0,
    estado: estado,
    repartidorNombre: repartidorNombre,
    creadoPor: 'admin',
    creadoEn: creadoEn.millisecondsSinceEpoch,
  );
}

void main() {
  group('Filtros.repartidores', () {
    final lista = [
      repartidor(uid: '1', nombre: 'Andrés Cedeño', cedula: '1712345675', vehiculoTipo: 'Moto'),
      repartidor(uid: '2', nombre: 'María Paz', cedula: '0912345678', vehiculoTipo: 'Automóvil', disponible: false),
      repartidor(uid: '3', nombre: 'Pedro Andrade', cedula: '1798765432', vehiculoTipo: 'Moto', disponible: false),
    ];

    test('sin criterios devuelve todo', () {
      expect(Filtros.repartidores(lista).length, 3);
    });

    test('busca por nombre sin distinguir mayúsculas', () {
      final r = Filtros.repartidores(lista, consulta: 'andr');
      expect(r.map((e) => e.uid), ['1', '3']); // Andrés y Andrade
    });

    test('busca por cédula parcial', () {
      final r = Filtros.repartidores(lista, consulta: '0912');
      expect(r.single.nombre, 'María Paz');
    });

    test('filtra por tipo de vehículo', () {
      final r = Filtros.repartidores(lista, tipoVehiculo: 'Moto');
      expect(r.length, 2);
    });

    test('filtra por disponibilidad', () {
      expect(Filtros.repartidores(lista, disponible: true).single.uid, '1');
      expect(Filtros.repartidores(lista, disponible: false).length, 2);
    });

    test('combina búsqueda y filtros', () {
      final r = Filtros.repartidores(lista, consulta: 'andr', tipoVehiculo: 'Moto', disponible: false);
      expect(r.single.nombre, 'Pedro Andrade');
    });

    test('consulta sin coincidencias devuelve vacío', () {
      expect(Filtros.repartidores(lista, consulta: 'zzz'), isEmpty);
    });
  });

  group('Filtros.pedidos', () {
    final lista = [
      pedido(
        id: 'a',
        clienteNombre: 'María López',
        repartidorNombre: 'Andrés Cedeño',
        estado: EstadoPedido.entregado,
        creadoEn: DateTime(2026, 7, 1, 10, 30),
      ),
      pedido(
        id: 'b',
        clienteNombre: 'Juan Pérez',
        estado: EstadoPedido.pendiente,
        creadoEn: DateTime(2026, 7, 5, 23, 59),
      ),
      pedido(
        id: 'c',
        clienteNombre: 'Lucía Mora',
        repartidorNombre: 'Pedro Andrade',
        estado: EstadoPedido.enRutaACliente,
        creadoEn: DateTime(2026, 7, 8, 0, 0),
      ),
    ];

    test('sin criterios devuelve todo', () {
      expect(Filtros.pedidos(lista).length, 3);
    });

    test('busca por nombre del cliente', () {
      expect(Filtros.pedidos(lista, consulta: 'juan').single.id, 'b');
    });

    test('busca por nombre del repartidor', () {
      final r = Filtros.pedidos(lista, consulta: 'andr');
      expect(r.map((e) => e.id), ['a', 'c']);
    });

    test('filtra por estado de la entrega', () {
      expect(Filtros.pedidos(lista, estado: EstadoPedido.entregado).single.id, 'a');
    });

    test('rango de fechas incluye los días extremos completos', () {
      final r = Filtros.pedidos(
        lista,
        desde: DateTime(2026, 7, 5),
        hasta: DateTime(2026, 7, 8),
      );
      // El pedido b (5 jul 23:59) y c (8 jul 00:00) entran; a (1 jul) no.
      expect(r.map((e) => e.id), ['b', 'c']);
    });

    test('solo fecha "desde"', () {
      final r = Filtros.pedidos(lista, desde: DateTime(2026, 7, 6));
      expect(r.single.id, 'c');
    });

    test('solo fecha "hasta"', () {
      final r = Filtros.pedidos(lista, hasta: DateTime(2026, 7, 1));
      expect(r.single.id, 'a');
    });

    test('combina búsqueda, estado y fechas', () {
      final r = Filtros.pedidos(
        lista,
        consulta: 'andr',
        estado: EstadoPedido.enRutaACliente,
        desde: DateTime(2026, 7, 8),
        hasta: DateTime(2026, 7, 8),
      );
      expect(r.single.id, 'c');
    });
  });
}
