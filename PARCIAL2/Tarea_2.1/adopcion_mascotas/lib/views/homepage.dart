import 'package:flutter/material.dart';
import 'mascotas_page.dart';
import 'solicitudes_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _paginaActual = 0;

  final List<Widget> _paginas = const [
    MascotasPage(),
    SolicitudesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _paginaActual,
        children: _paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (i) => setState(() => _paginaActual = i),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets),        label: 'Mascotas'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Solicitudes'),
        ],
      ),
    );
  }
}