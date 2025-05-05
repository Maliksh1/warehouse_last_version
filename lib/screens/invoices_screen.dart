import 'package:flutter/material.dart';

class InvoicesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> invoices = [
    {"number": "#INV1001", "status": "غير مدفوعة", "amount": 320.5},
    {"number": "#INV1002", "status": "مدفوعة", "amount": 200.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الفواتير")),
      body: ListView(
        children: invoices.map((invoice) {
          final isPaid = invoice["status"] == "مدفوعة";
          return Card(
            child: ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text(invoice["number"]),
              subtitle: Text("المبلغ: ${invoice["amount"]} ريال"),
              trailing: Text(invoice["status"],
                  style: TextStyle(
                      color: isPaid ? Colors.green : Colors.redAccent)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
