import 'package:flutter/material.dart';

import 'registro_chofer_view.dart';

class WelcomeView extends StatelessWidget {

  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.blueGrey[50],

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Container(

                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black12,
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.local_taxi,
                  size: 120,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Sistema de Nómina',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Gestión de pago semanal para choferes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  icon: const Icon(Icons.arrow_forward),

                  label: const Text(
                    'Ingresar',
                    style: TextStyle(fontSize: 18),
                  ),

                  style: ElevatedButton.styleFrom(

                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistroView(),
                      ),
                    );

                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}