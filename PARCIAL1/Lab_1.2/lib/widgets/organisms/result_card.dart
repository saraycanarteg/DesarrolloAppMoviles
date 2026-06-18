import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData icon;

  const ResultCard({
    required this.title,
    required this.children,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 30, thickness: 1.2),
            ...children,
          ],
        ),
      ),
    );
  }
}
