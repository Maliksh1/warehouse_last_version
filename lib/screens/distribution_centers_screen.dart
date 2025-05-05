import 'package:flutter/material.dart';

class DistributionCentersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> centers = [
    {"name": "مركز الرياض", "location": "الرياض"},
    {"name": "مركز جدة", "location": "جدة"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("مراكز التوزيع")),
      body: ListView(
        children: centers
            .map((c) => Card(
                  child: ListTile(
                    leading: Icon(Icons.map),
                    title: Text(c["name"]),
                    subtitle: Text("الموقع: ${c["location"]}"),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
