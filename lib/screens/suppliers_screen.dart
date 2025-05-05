import 'package:flutter/material.dart';

class SuppliersScreen extends StatelessWidget {
  final List<Map<String, String>> suppliers = [
    {"name": "مؤسسة التوريد الشامل", "contact": "0111234567"},
    {"name": "مورد الأجهزة الذكية", "contact": "0509876543"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الموردين")),
      body: ListView(
        children: suppliers
            .map((s) => ListTile(
                  leading: Icon(Icons.store),
                  title: Text(s["name"]!),
                  subtitle: Text("الاتصال: ${s["contact"]}"),
                ))
            .toList(),
      ),
    );
  }
}
