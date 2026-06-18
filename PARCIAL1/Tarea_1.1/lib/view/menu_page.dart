import 'package:flutter/material.dart';
import 'cajero_view.dart';
import 'vuelto_view.dart';
import 'bisiesto_view.dart';
import 'perfecto_view.dart';
import 'peso_view.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Menú Principal",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2C5F7F),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE8EEF5)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                _buildMenuCard(
                  context,
                  title: "Ejercicio 1",
                  subtitle: "Cajero",
                  icon: Icons.money,
                  color: Color(0xFF4CAF50),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CajeroPage()),
                  ),
                ),
                SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  title: "Ejercicio 2",
                  subtitle: "Vuelto",
                  icon: Icons.payment,
                  color: Color(0xFF2196F3),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VueltoPage()),
                  ),
                ),
                SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  title: "Ejercicio 3",
                  subtitle: "Año Bisiesto",
                  icon: Icons.calendar_today,
                  color: Color(0xFFFF9800),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BisiestoPage()),
                  ),
                ),
                SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  title: "Ejercicio 4",
                  subtitle: "Número Perfecto",
                  icon: Icons.diamond,
                  color: Color(0xFF9C27B0),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PerfectoPage()),
                  ),
                ),
                SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  title: "Ejercicio 5",
                  subtitle: "Control de Peso",
                  icon: Icons.scale,
                  color: Color(0xFFF44336),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PesoPage()),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}