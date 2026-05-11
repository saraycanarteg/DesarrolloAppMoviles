import 'package:flutter/material.dart';
import 'view/menu_page.dart';

void main() {
  runApp(MainMenuPage());
}

class  MainMenuPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ejercicios",
      theme: ThemeData(primaryColor: Colors.blue),
      home: MenuPage(),
    );
  }
}