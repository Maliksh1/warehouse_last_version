import 'package:flutter/material.dart';

class GarageScreen extends StatelessWidget {
  final List<String> vehiclesInGarage = ["شاحنة 2", "شاحنة 5"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المرآب")),
      body: ListView.builder(
        itemCount: vehiclesInGarage.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.garage),
          title: Text(vehiclesInGarage[index]),
          subtitle: Text("قيد الصيانة"),
        ),
      ),
    );
  }
}
