import 'package:flutter/material.dart';

class EmployeesScreen extends StatelessWidget {
  final List<Map<String, String>> employees = [
    {"name": "أحمد الزهراني", "role": "مدير مستودع"},
    {"name": "سارة الحربي", "role": "مسؤولة طلبات"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الموظفين")),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final emp = employees[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text(emp["name"]!),
              subtitle: Text(emp["role"]!),
              trailing: IconButton(icon: Icon(Icons.edit), onPressed: () {}),
            ),
          );
        },
      ),
    );
  }
}
