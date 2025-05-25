import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/providers/locale_provider.dart';
import 'package:warehouse/providers/navigation_provider.dart'; // إضافة استيراد navigation_provider

// This widget is the static sidebar content
class SidebarMenu extends ConsumerWidget {
  const SidebarMenu({super.key});

  // Helper to build individual menu items
  Widget _buildMenuItem(BuildContext context, WidgetRef ref, IconData icon,
      String titleKey, int index) {
    final t = AppLocalizations.of(context)!;
    // Watch the selected page index
    final selectedIndex = ref.watch(selectedPageIndexProvider);

    // Item is selected only if the selectedIndex is non-negative and matches the item's index
    final bool isSelected = selectedIndex >= 0 && selectedIndex == index;

    final selectedPageIndexNotifier =
        ref.read(selectedPageIndexProvider.notifier);

    // إضافة الوصول إلى navigation notifier
    final navigationNotifier = ref.read(navigationProvider.notifier);

    return ListTile(
      leading: Icon(icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
      title: Text(t.get(titleKey),
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )),
      tileColor: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      selected: isSelected,
      onTap: () {
        // Update the selected page index provider's state
        selectedPageIndexNotifier.state = index;

        // تحديث حالة التنقل أيضاً عند النقر على عنصر القائمة
        navigationNotifier.goToMainSection(index);

        // If on a small screen (using Drawer), close the drawer
        if (Scaffold.of(context).hasDrawer) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    // List of menu items with their index and localization key
    // Indices MUST match the order of widgets in _mainSectionContent list in AppContainer
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.dashboard,
        'title_key': 'dashboard',
        'index': 0
      }, // Dashboard Overview
      {
        'icon': Icons.warehouse,
        'title_key': 'warehouses',
        'index': 1
      }, // Warehouses
      {
        'icon': Icons.inventory,
        'title_key': 'products',
        'index': 2
      }, // Products
      {'icon': Icons.people, 'title_key': 'employees', 'index': 3}, // Employees
      {
        'icon': Icons.map,
        'title_key': 'distribution_centers',
        'index': 4
      }, // Distribution Centers
      {'icon': Icons.person, 'title_key': 'customers', 'index': 5}, // Customers
      {
        'icon': Icons.local_shipping,
        'title_key': 'vehicles',
        'index': 6
      }, // Vehicles
      {
        'icon': Icons.receipt_long,
        'title_key': 'invoices',
        'index': 7
      }, // Invoices
      {'icon': Icons.store, 'title_key': 'suppliers', 'index': 8}, // Suppliers
      {
        'icon': Icons.category,
        'title_key': 'categories',
        'index': 9
      }, // Categories
      {
        'icon': Icons.star,
        'title_key': 'specializations',
        'index': 10
      }, // Specializations
      {
        'icon': Icons.alt_route,
        'title_key': 'transport_tasks',
        'index': 11
      }, // Transport Tasks
      {'icon': Icons.garage, 'title_key': 'garage', 'index': 12}, // Garage
      // TODO: Add Settings menu item if needed (assign index 13 or next available)
    ];

    return Container(
      width: 240,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)]),
      child: Column(
        children: [
          Container(
            height: 60,
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.warehouse,
                    color: Theme.of(context).colorScheme.onPrimary, size: 28),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    t.get('app_title'),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menuItems.map((item) {
                return _buildMenuItem(context, ref, item['icon'],
                    item['title_key'], item['index']);
              }).toList(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            title: Text('Logout',
                style:
                    Theme.of(context).textTheme.bodyMedium), // TODO: Localize
            onTap: () {
              // TODO: Implement Logout logic
            },
          )
        ],
      ),
    );
  }
}

// تعريف provider لمؤشر الصفحة المحددة إذا لم يكن موجوداً في مكان آخر
final selectedPageIndexProvider = StateProvider<int>((ref) => 0);
