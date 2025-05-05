import 'package:flutter/material.dart';
import '../screens/products_screen.dart';
import '../screens/warehouses_screen.dart';
import '../screens/employees_screen.dart';
import '../screens/distribution_centers_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/vehicles_screen.dart';
import '../screens/invoices_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/specializations_screen.dart';
import '../screens/transport_tasks_screen.dart';
import '../screens/garage_screen.dart';
import '../lang/app_localizations.dart';

class SidebarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      width: 240,
      color: Colors.blueGrey[50],
      child: Column(
        children: [
          Container(
            height: 60,
            color: Colors.blue[800],
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.warehouse, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    t.get('app_title'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                    context, Icons.dashboard, t.get('dashboard'), null),
                _buildMenuItem(context, Icons.warehouse, t.get('warehouses'),
                    WarehousesScreen()),
                _buildMenuItem(context, Icons.inventory, t.get('products'),
                    ProductsScreen()),
                _buildMenuItem(context, Icons.people, t.get('employees'),
                    EmployeesScreen()),
                _buildMenuItem(context, Icons.map,
                    t.get('distribution_centers'), DistributionCentersScreen()),
                _buildMenuItem(context, Icons.person, t.get('customers'),
                    CustomersScreen()),
                _buildMenuItem(context, Icons.local_shipping, t.get('vehicles'),
                    VehiclesScreen()),
                _buildMenuItem(context, Icons.receipt_long, t.get('invoices'),
                    InvoicesScreen()),
                _buildMenuItem(context, Icons.store, t.get('suppliers'),
                    SuppliersScreen()),
                _buildMenuItem(context, Icons.category, t.get('categories'),
                    CategoriesScreen()),
                _buildMenuItem(context, Icons.star, t.get('specializations'),
                    SpecializationsScreen()),
                _buildMenuItem(context, Icons.alt_route,
                    t.get('transport_tasks'), TransportTasksScreen()),
                _buildMenuItem(
                    context, Icons.garage, t.get('garage'), GarageScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, Widget? screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(title, style: TextStyle(fontSize: 14)),
      onTap: screen == null
          ? null
          : () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => screen),
              );
            },
      hoverColor: Colors.blue[50],
    );
  }
}
