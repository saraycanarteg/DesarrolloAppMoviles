import 'package:flutter/material.dart';
import 'view/home_choferes_view.dart';
import 'view/resultado_choferes_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nómina de Choferes',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeChoferesView(),
        '/resultado': (context) => const ResultadoChoferesView(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
