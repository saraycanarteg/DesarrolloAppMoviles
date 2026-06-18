import 'package:flutter/material.dart';
import 'view/home_servicios_view.dart';
import 'view/resultado_servicios_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Servicios Básicos',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeServiciosView(),
        '/resultado': (context) => ResultadoServiciosView(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
