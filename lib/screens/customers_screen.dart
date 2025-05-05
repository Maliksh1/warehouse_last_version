import 'package:flutter/material.dart';

class CustomersScreen extends StatelessWidget {
  final List<Map<String, String>> customers = [
    {"name": "شركة الخليج", "contact": "0551234567"},
    {"name": "شركة النور", "contact": "0549876543"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الزبائن")),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final c = customers[index];
          return ListTile(
            leading: Icon(Icons.business),
            title: Text(c["name"]!),
            subtitle: Text("الهاتف: ${c["contact"]}"),
          );
        },
      ),
    );
  }
}
