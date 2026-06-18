import 'package:flutter/material.dart';
import 'view/common/splash_screen_view.dart';
import 'view/common/menu_view.dart';
import 'view/problema1/home_page_view.dart';
import 'view/problema1/resultado_page_view.dart';
import 'view/problema2/profesor_view.dart';
import 'view/problema2/resultado_profesor_view.dart';
import 'view/problema3/home_page_view.dart' as problema3;
import 'view/problema3/resultado_page_view.dart' as resultado_problema3;
import 'view/problema4/home_page_view.dart' as problema4;
import 'view/problema4/resultado_page_view.dart';

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
        '/problema2': (context) => ProfesorView(),
        '/resultado_profesor': (context) => ResultadoProfesorView(),
        '/problema3': (context) => problema3.Problema3HomeView(),
        '/resultado_problema3': (context) => resultado_problema3.Problema3ResultadoView(),
        '/problema4': (context) => problema4.Problema4HomeView(),
        '/resultado_problema4': (context) => Problema4ResultadoView(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
    );
  }
}
