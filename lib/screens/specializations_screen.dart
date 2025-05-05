import 'package:flutter/material.dart';

class SpecializationsScreen extends StatelessWidget {
  final List<String> specs = ["إدارة المستودع", "توزيع", "مراقبة جودة"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الاختصاصات")),
      body: ListView(
        children: specs
            .map((spec) => ListTile(
                  leading: Icon(Icons.star),
                  title: Text(spec),
                ))
            .toList(),
      ),
    );
  }
}
