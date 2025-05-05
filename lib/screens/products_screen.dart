import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "name": "منتج 1",
      "code": "P001",
      "supplier": "مورد أ",
      "category": "أجهزة",
      "quantity": 5,
      "cost": 100,
      "price": 150,
      "status": "منخفض"
    },
    {
      "name": "منتج 2",
      "code": "P002",
      "supplier": "مورد ب",
      "category": "ملحقات",
      "quantity": 20,
      "cost": 50,
      "price": 75,
      "status": "متوفر"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المنتجات")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add_box),
                    label: Text("إضافة منتج")),
                SizedBox(width: 10),
                ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.download),
                    label: Text("تصدير المنتجات")),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("الصورة")),
                  DataColumn(label: Text("الاسم")),
                  DataColumn(label: Text("الكود")),
                  DataColumn(label: Text("القسم")),
                  DataColumn(label: Text("المورد")),
                  DataColumn(label: Text("الكمية")),
                  DataColumn(label: Text("التكلفة")),
                  DataColumn(label: Text("السعر")),
                  DataColumn(label: Text("الحالة")),
                  DataColumn(label: Text("إجراءات")),
                ],
                rows: products.map((product) {
                  final statusColor = product["status"] == "منخفض"
                      ? Colors.orange
                      : Colors.green;

                  return DataRow(cells: [
                    DataCell(Icon(Icons.image)),
                    DataCell(Text(product["name"])),
                    DataCell(Text(product["code"])),
                    DataCell(Text(product["category"])),
                    DataCell(Text(product["supplier"])),
                    DataCell(Text(product["quantity"].toString())),
                    DataCell(Text("${product["cost"]} \$")),
                    DataCell(Text("${product["price"]} \$")),
                    DataCell(Text(product["status"],
                        style: TextStyle(color: statusColor))),
                    DataCell(Row(
                      children: [
                        IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                        IconButton(icon: Icon(Icons.delete), onPressed: () {}),
                        IconButton(
                            icon: Icon(Icons.info_outline), onPressed: () {}),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
