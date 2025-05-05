import 'package:flutter/material.dart';

class VehiclesScreen extends StatelessWidget {
  final List<Map<String, String>> vehicles = [
    {"id": "شاحنة 1", "status": "متوفرة"},
    {"id": "شاحنة 2", "status": "قيد الصيانة"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الآليات")),
      body: ListView(
        children: vehicles
            .map((v) => ListTile(
                  leading: Icon(Icons.local_shipping),
                  title: Text(v["id"]!),
                  subtitle: Text("الحالة: ${v["status"]}"),
                  trailing: Icon(Icons.settings),
                ))
            .toList(),
      ),
    );
  }
}
