import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  final List<String> categories = ["معدات", "ملحقات", "قطع غيار"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الأقسام")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.category),
          title: Text(categories[index]),
        ),
      ),
    );
  }
}
