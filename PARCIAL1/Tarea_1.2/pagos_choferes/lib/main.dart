import 'package:flutter/material.dart';

import 'views/bienvenida_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Sistema de Nómina',

      theme: ThemeData(

        primarySwatch: Colors.blue,

        scaffoldBackgroundColor: Colors.grey[100],

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(

          style: ElevatedButton.styleFrom(

            backgroundColor: Colors.blue,

            foregroundColor: Colors.white,

            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),

      home: const WelcomeView(),
    );
  }
}