import 'package:flutter/material.dart';

class WarehousesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> warehouses = [
    {"name": "المستودع الرئيسي", "capacity": 100, "used": 65},
    {"name": "مستودع الجنوب", "capacity": 50, "used": 40},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المستودعات")),
      body: ListView.builder(
        itemCount: warehouses.length,
        itemBuilder: (context, index) {
          final warehouse = warehouses[index];
          double usage = warehouse["used"] / warehouse["capacity"];

          return Card(
            child: ListTile(
              title: Text(warehouse["name"]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: usage, color: Colors.blue),
                  SizedBox(height: 5),
                  Text(
                      "الإشغال: ${warehouse["used"]}/${warehouse["capacity"]}"),
                ],
              ),
              trailing: Icon(Icons.warehouse_outlined),
            ),
          );
        },
      ),
    );
  }
}
