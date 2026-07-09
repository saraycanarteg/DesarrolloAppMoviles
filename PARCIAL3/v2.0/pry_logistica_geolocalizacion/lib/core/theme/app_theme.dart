import 'package:flutter/material.dart';

/// Tema visual global de la app de logística.
class AppTheme {
  static const Color colorPrimario = Color(0xFF1E5AA8); // azul logístico
  static const Color colorAcento = Color(0xFFFF8A3D); // naranja de entregas

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: colorPrimario,
      primary: colorPrimario,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIconColor: colorPrimario,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimario,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        surfaceTintColor: Colors.white,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: const ChipThemeData(
        labelStyle: TextStyle(color: Colors.white, fontSize: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: colorPrimario,
      ),
    );
  }
}

/// Helpers de presentación para el estado de un pedido.
class EstadoPedidoUi {
  static String etiqueta(String estadoRaw) {
    switch (estadoRaw) {
      case 'pendiente':
        return 'Pendiente';
      case 'esperando_confirmacion':
        return 'Esperando confirmación';
      case 'asignado':
        return 'Asignado';
      case 'en_ruta_a_tienda':
        return 'En ruta a tienda';
      case 'recogido':
        return 'Recogido';
      case 'en_ruta_a_cliente':
        return 'En ruta a cliente';
      case 'en_ruta': // datos legados
        return 'En ruta';
      case 'entregado':
        return 'Entregado';
      default:
        return estadoRaw;
    }
  }

  static Color color(String estadoRaw) {
    switch (estadoRaw) {
      case 'pendiente':
        return Colors.orange;
      case 'esperando_confirmacion':
        return Colors.blue;
      case 'asignado':
        return Colors.indigo;
      case 'en_ruta_a_tienda':
        return Colors.deepOrange;
      case 'recogido':
        return Colors.purple;
      case 'en_ruta_a_cliente':
      case 'en_ruta': // datos legados
        return Colors.teal;
      case 'entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
