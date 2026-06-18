import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/mascota_viewmodel.dart';
import 'viewmodels/solicitud_viewmodel.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MascotaViewmodel()),
        ChangeNotifierProvider(create: (_) => SolicitudViewmodel()),
      ],
      child: MaterialApp(
        title: 'Adopción de Mascotas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}