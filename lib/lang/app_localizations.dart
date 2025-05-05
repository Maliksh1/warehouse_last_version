import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // الوصول من أي مكان في التطبيق
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // جميع النصوص المترجمة
  static const _localizedValues = {
    'en': {
      'app_title': 'Warehouse App',
      'dashboard': 'Dashboard',
      'products': 'Products',
      'warehouses': 'Warehouses',
      'employees': 'Employees',
      'distribution_centers': 'Distribution Centers',
      'customers': 'Customers',
      'vehicles': 'Vehicles',
      'invoices': 'Invoices',
      'suppliers': 'Suppliers',
      'categories': 'Categories',
      'specializations': 'Specializations',
      'transport_tasks': 'Transport Tasks',
      'garage': 'Garage',

      // KPIs
      'kpi_inventory': 'Inventory',
      'kpi_tasks': 'Tasks',
      'kpi_vehicles': 'Vehicles',
      'kpi_invoices': 'Invoices',

      // Quick Actions
      'new_task': 'New Task',
      'new_product': 'New Product',
      'new_invoice': 'New Invoice',

      // Product Table
      'add_product': 'Add Product',
      'export_products': 'Export Products',
      'status': 'Status',
      'available': 'Available',
      'low': 'Low',
      'out_of_stock': 'Out of Stock',
      'edit': 'Edit',
      'delete': 'Delete',
      'details': 'Details',

      // Charts
      'warehouse_chart': 'Warehouse Status Chart',
      'task_chart': 'Task Status Chart',
    },
    'ar': {
      'app_title': 'تطبيق المستودعات',
      'dashboard': 'لوحة التحكم',
      'products': 'المنتجات',
      'warehouses': 'المستودعات',
      'employees': 'الموظفين',
      'distribution_centers': 'مراكز التوزيع',
      'customers': 'الزبائن',
      'vehicles': 'الآليات',
      'invoices': 'الفواتير',
      'suppliers': 'الموردين',
      'categories': 'الأقسام',
      'specializations': 'الاختصاصات',
      'transport_tasks': 'مهمات النقل',
      'garage': 'المرآب',

      // KPIs
      'kpi_inventory': 'المخزون',
      'kpi_tasks': 'المهام',
      'kpi_vehicles': 'الآليات',
      'kpi_invoices': 'الفواتير',

      // Quick Actions
      'new_task': 'مهمة جديدة',
      'new_product': 'منتج جديد',
      'new_invoice': 'فاتورة جديدة',

      // Product Table
      'add_product': 'إضافة منتج',
      'export_products': 'تصدير المنتجات',
      'status': 'الحالة',
      'available': 'متوفر',
      'low': 'منخفض',
      'out_of_stock': 'نافد',
      'edit': 'تعديل',
      'delete': 'حذف',
      'details': 'تفاصيل',

      // Charts
      'warehouse_chart': 'رسم بياني لحالة المستودعات',
      'task_chart': 'رسم بياني لحالة المهام',
    }
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

// هذا هو الـ delegate اللي لازم نضيفه لـ MaterialApp
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
