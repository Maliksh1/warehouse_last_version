import 'package:flutter/material.dart';

class TransportTasksScreen extends StatelessWidget {
  final List<Map<String, String>> tasks = [
    {"id": "T-001", "status": "مجدولة"},
    {"id": "T-002", "status": "متأخرة"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("مهمات النقل")),
      body: ListView(
        children: tasks
            .map((task) => ListTile(
                  leading: Icon(Icons.alt_route),
                  title: Text("مهمة ${task["id"]}"),
                  subtitle: Text("الحالة: ${task["status"]}"),
                ))
            .toList(),
      ),
    );
  }
}
