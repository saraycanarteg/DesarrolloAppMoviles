import 'package:flutter/material.dart';
import 'view/common/splash_screen_view.dart';
import 'view/common/menu_view.dart';
import 'view/problema1/home_page_view.dart';
import 'view/problema1/resultado_page_view.dart';
import 'view/problema2/profesor_view.dart';
import 'view/problema2/resultado_profesor_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Laboratorio 2",
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreenView(),
        '/menu': (context) => MenuView(),
        '/problema1': (context) => HomePaginaView(),
        '/resultado': (context) => ResultadoPageView(),
        '/profesor': (context) => ProfesorView(),
        '/resultado_profesor': (context) => ResultadoProfesorView(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
    );
  }
}
