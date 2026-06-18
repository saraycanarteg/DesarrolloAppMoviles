import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/luz_provider.dart';
import 'views/luz_view.dart';
import 'views/home_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LuzProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 0;
  final screens = const [
    HomeView(),
    LuzView(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detector de Luz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: screens[index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          onTap: (i) => setState(() => index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.light_mode), label: "Luz"),
          ],
        ),
      ),
    );
  }
}
