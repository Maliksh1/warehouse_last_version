import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  KpiCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: MediaQuery.of(context).size.width / 4.4,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 32),
            SizedBox(height: 10),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
