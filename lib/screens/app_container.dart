import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/widgets/sidebar_menu.dart';
import 'package:warehouse/providers/locale_provider.dart';
import 'package:warehouse/providers/navigation_provider.dart'; // Import NEW navigation provider
import 'package:warehouse/lang/app_localizations.dart';

// Import all your screens (main sections and special ones)
import 'package:warehouse/screens/dashboard_home.dart';
import 'package:warehouse/screens/warehouses_screen.dart';
import 'package:warehouse/screens/products_screen.dart';
import 'package:warehouse/screens/employees_screen.dart';
import 'package:warehouse/screens/distribution_centers_screen.dart';
import 'package:warehouse/screens/customers_screen.dart';
import 'package:warehouse/screens/vehicles_screen.dart';
import 'package:warehouse/screens/invoices_screen.dart';
import 'package:warehouse/screens/suppliers_screen.dart';
import 'package:warehouse/screens/categories_screen.dart';
import 'package:warehouse/screens/specializations_screen.dart';
import 'package:warehouse/screens/transport_tasks_screen.dart';
import 'package:warehouse/screens/garage_screen.dart';
// TODO: Add settings_screen.dart
import 'package:warehouse/screens/create_transport_task_screen.dart'; // Keep if used
// REMOVED: import 'package:warehouse/screens/create_warehouse_screen.dart'; // No longer a full screen

// NEW: Import detail screens
import 'package:warehouse/screens/warehouse_details_screen.dart'; // Need to create
import 'package:warehouse/screens/product_details_screen.dart'; // Need to create

// This widget will contain the main Scaffold, AppBar, Sidebar, and the content area
class AppContainer extends ConsumerWidget {
  AppContainer({super.key});

  // List of all main section content widgets, corresponding to sidebar indices 0..12+
  // Keep this ordered according to the index in SidebarMenu
  final List<Widget> _mainSectionContent = [
    DashboardHome(), // 0
    WarehousesScreen(), // 1
    ProductsScreen(), // 2
    EmployeesScreen(), // 3
    DistributionCentersScreen(), // 4
    CustomersScreen(), // 5
    VehiclesScreen(), // 6
    InvoicesScreen(), // 7
    SuppliersScreen(), // 8
    CategoriesScreen(), // 9
    SpecializationsScreen(), // 10
    TransportTasksScreen(), // 11
    GarageScreen(), // 12
    // TODO: Add SettingsScreen() if needed (e.g., index 13)
  ];

  // Helper to get the AppBar title based on the current navigation state
  String _getPageTitle(NavigationState state, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // استخدام switch على نوع الحالة بدلاً من when
    switch (state) {
      case MainSectionNavigationState():
        // Get title for main sections
        if (state.index >= 0 && state.index < _mainSectionContent.length) {
          switch (state.index) {
            case 0:
              return localizations.get('dashboard');
            case 1:
              return localizations.get('warehouses');
            case 2:
              return localizations.get('products');
            case 3:
              return localizations.get('employees');
            case 4:
              return localizations.get('distribution_centers');
            case 5:
              return localizations.get('customers');
            case 6:
              return localizations.get('vehicles');
            case 7:
              return localizations.get('invoices');
            case 8:
              return localizations.get('suppliers');
            case 9:
              return localizations.get('categories');
            case 10:
              return localizations.get('specializations');
            case 11:
              return localizations.get('transport_tasks');
            case 12:
              return localizations.get('garage');
            // TODO: Add case for settings if added (e.g., case 13)
            default:
              return localizations.get('app_title'); // Fallback
          }
        }
        return localizations.get('app_title'); // Fallback

      case CreateTaskNavigationState():
        return localizations.get('create_new_task');

      case WarehouseDetailsNavigationState():
        return localizations.get('warehouse_details_title') ??
            'Warehouse Details';

      case ProductDetailsNavigationState():
        return localizations.get('product_details_title') ?? 'Product Details';
    }
  }

  // Helper to get the main content widget based on the current navigation state
  Widget _getPageContent(NavigationState state) {
    // استخدام switch على نوع الحالة بدلاً من when
    switch (state) {
      case MainSectionNavigationState():
        // Display the content for the selected main section using IndexedStack
        if (state.index >= 0 && state.index < _mainSectionContent.length) {
          return IndexedStack(
            index: state.index, // Use the index from the state
            children: _mainSectionContent,
          );
        }
        return Center(
            child: Text(
                'Error: Unknown main section index ${state.index}')); // Fallback

      case CreateTaskNavigationState():
        return const CreateTransportTaskScreen(); // Display Create Task screen

      case WarehouseDetailsNavigationState():
        return WarehouseDetailScreen(
          warehouseId: state.warehouseId,
          warehouse: Warehouse(
              id: "",
              name: "name",
              address: "address",
              capacityUnit: "400",
              location: "location",
              used: 20,
              manager: "manager",
              productIds: "productIds",
              usedCapacity: 40,
              capacity: 50,
              occupied: 10),
        );

//Display Warehouse Details screen

      case ProductDetailsNavigationState():
        return ProductDetailsScreen(
          productId: state.productId,
        ); // Display Product Details screen
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current navigation state from the provider
    final currentNavigationState = ref.watch(navigationProvider);

    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    final bool isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(currentNavigationState, context)),
        // Show drawer icon only on small screens AND when in a main section view
        leading: !isLargeScreen &&
                currentNavigationState is MainSectionNavigationState
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              )
            : currentNavigationState
                    is! MainSectionNavigationState // If not in main section, potentially show a back button
                ? IconButton(
                    // Back button
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      ref
                          .read(navigationProvider.notifier)
                          .back(); // Call the back method on the notifier
                    },
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                  )
                : null,

        actions: [
          // Only show search/notifications/user icon when in a main section view
          if (currentNavigationState is MainSectionNavigationState) ...[
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  print("Search pressed");
                }),
            IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  print("Notifications pressed");
                }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                child: const Icon(Icons.person_outline),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                radius: 18,
              ),
            ),
          ],
          // Language Toggle Button (Keep visible on all screens)
          TextButton(
            onPressed: () {
              localeNotifier.toggleLocale();
            },
            child: Text(
              currentLocale.languageCode == 'ar' ? 'English' : 'العربية',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // The Drawer content is SidebarMenu
      // Show drawer only on small screens AND when in a main section view
      drawer:
          !isLargeScreen && currentNavigationState is MainSectionNavigationState
              ? const Drawer(child: SidebarMenu())
              : null,

      body: Row(
        // Main layout row
        children: [
          // Show permanent sidebar on large screens
          if (isLargeScreen) const SidebarMenu(),

          // Main content area takes the remaining space
          Expanded(
            // --- Display content based on the current navigation state ---
            child: _getPageContent(
                currentNavigationState), // Use the helper to get the correct widget
          ),
        ],
      ),
    );
  }
}

// --- Add new localization keys ---
/*
// In lib/lang/en.json and lib/lang/ar.json:
"warehouse_details_title": "Warehouse Details", // Add key
"product_details_title": "Product Details", // Add key
// Add keys for fields in StockItem model if needed (location, quantity, expiryDate)
"location": "Location", // Already exists
"quantity": "Quantity", // Already exists
"expiry_date": "Expiry Date", // Add key
"stock_items": "Stock Items", // Add key for section title
"items_in_this_warehouse": "Items in this warehouse", // Add key for section title
"statistics": "Statistics", // Add key for section title
"total_stock_value": "Total Stock Value", // Add key
"items_near_expiry": "Items Near Expiry", // Add key
"categories_in_warehouse": "Categories in Warehouse", // Add key
"products_in_category": "Products in Category", // Add key
"general_info": "General Info", // Add key
"stock_locations": "Stock Locations", // Add key

// Add keys for StockItem statuses if you add status to StockItem model
*/
