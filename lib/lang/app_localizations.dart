import 'package:flutter/material.dart';

// Handles localization by looking up in hardcoded maps
// This version does NOT load from JSON files. Data is within _localizedValues.
class AppLocalizations {
  final Locale locale; // Current locale

  AppLocalizations(this.locale);

  // Access from anywhere
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // All translated texts - HARDCODED MAP
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      "app_title": "Warehouse App",
      "dashboard": "Dashboard",
      "products": "Products",
      "warehouses": "Warehouses",
      "employees": "Employees",
      "distribution_centers": "Distribution Centers",
      "customers": "Customers",
      "vehicles": "Vehicles",
      "invoices": "Invoices",
      "suppliers": "Suppliers",
      "categories": "Categories",
      "specializations": "Specializations",
      "transport_tasks": "Transport Tasks",
      "garage": "Garage",

      // KPIs
      "kpi_inventory": "Inventory",
      "kpi_tasks": "Tasks",
      "kpi_vehicles": "Vehicles",
      "kpi_invoices": "Invoices",

      // Quick Actions
      "quick_actions_title": "Quick Actions",
      "new_task": "New Task",
      "new_product": "New Product",
      "new_invoice": "New Invoice",

      // Product Table & General Table
      "add_product": "Add Product",
      "export_products": "Export Products",
      "status": "Status",
      "available": "Available",
      "low": "Low",
      "out_of_stock": "Out of Stock",
      "edit": "Edit",
      "delete": "Delete",
      "details": "Details",
      "name": "Name",
      "code": "Code",
      "category": "Category",
      "supplier": "Supplier",
      "quantity": "Quantity",
      "actions": "Actions",
      "cost": "Cost",
      "price": "Price",
      "image": "Image",

      // Charts
      "warehouse_chart": "Warehouse Status Chart",
      "task_chart": "Task Status Chart",

      // General UI / Buttons / Labels
      "search_placeholder": "Search...",
      "add_new_warehouse_button": "Add New Warehouse",
      "occupancy": "Occupancy",
      "add_new_customer_button": "Add New Customer",
      "add_new_employee_button": "Add New Employee",
      "add_new_distribution_center_button": "Add New Center",
      "add_new_vehicle_button": "Add New Vehicle",
      "create_new_invoice_button": "Create New Invoice",
      "add_new_supplier_button": "Add New Supplier",
      "add_new_category_button": "Add New Category",
      "add_new_specialization_button": "Add New Specialty",
      "create_new_task_button": "Create New Task", // Added
      "log_maintenance_button": "Log Maintenance",
      "id": "ID",
      "contact": "Contact",
      "location": "Location",
      "role": "Role",
      "vehicle": "Vehicle",
      "number": "Number",
      "amount": "Amount",
      "title": "Title",
      "address": "Address",
      "capacity": "Capacity",
      "used": "Used",
      "no_data_available": "No data available.",
      "resolve": "Resolve",
      "cancel": "Cancel",
      // en.json
      "select_warehouse": "Select Warehouse",
      "choose_warehouse": "Choose a warehouse",

      "description": "Description",
      "import_cycle": "Import Cycle",

      "type_id": "Type ID",
      "unit": "Unit",
      "actual_piece_price": "Piece Price",
      "save": "Save",

      "required_field": "This field is required",
      "invalid_number": "Please enter a valid number",
      "product_added_successfully": "Product added successfully"

      // Added
    },
    'ar': {
      // ar.json
      "select_warehouse": "اختر المستودع",
      "choose_warehouse": "اختر مستودعاً",

      "app_title": "تطبيق المستودعات",
      "dashboard": "لوحة التحكم",
      "products": "المنتجات",
      "warehouses": "المستودعات",
      "employees": "الموظفين",
      "distribution_centers": "مراكز التوزيع",
      "customers": "الزبائن",
      "vehicles": "الآليات",
      "invoices": "الفواتير",
      "suppliers": "الموردين",
      "categories": "الأقسام",
      "specializations": "الاختصاصات",
      "transport_tasks": "مهمات النقل",
      "garage": "المرآب",
      "product_added_successfully": "تمت إضافة المنتج بنجاح",
      "add_product": "إضافة منتج",
      "product_name": "اسم المنتج",
      "category": "الفئة",
      "supplier": "المورد",
      "price": "السعر",
      "cost": "التكلفة",
      "save": "حفظ",
      "cancel": "إلغاء",

      // KPIs
      "kpi_inventory": "المخزون",
      "kpi_tasks": "المهام",
      "kpi_vehicles": "الآليات",
      "kpi_invoices": "الفواتير",

      // Quick Actions
      "quick_actions_title": "إجراءات سريعة",
      "new_task": "مهمة جديدة", // Already exists
      "new_product": "منتج جديد", // Already exists
      "new_invoice": "فاتورة جديدة", // Already exists

      // Product Table & General Table

      "export_products": "تصدير المنتجات",
      "status": "الحالة",
      "available": "متوفر",
      "low": "منخفض",
      "out_of_stock": "نافد",
      "edit": "تعديل",
      "delete": "حذف",
      "details": "تفاصيل",
      "name": "الاسم",
      "code": "الكود",

      "quantity": "الكمية",
      "actions": "إجراءات",

      "image": "الصورة",

      // Charts
      "warehouse_chart": "رسم بياني لحالة المستودعات",
      "task_chart": "رسم بياني لحالة المهام",

      // General UI / Buttons / Labels
      "search_placeholder": "بحث...",
      "add_new_warehouse_button": "إضافة مستودع جديد",
      "occupancy": "الإشغال",
      "add_new_customer_button": "إضافة زبون جديد",
      "add_new_employee_button": "إضافة موظف جديد",
      "add_new_distribution_center_button": "إضافة مركز جديد",
      "add_new_vehicle_button": "إضافة آلية جديدة",
      "create_new_invoice_button": "إنشاء فاتورة جديدة", // Added
      "add_new_supplier_button": "إضافة مورد جديد",
      "add_new_category_button": "إضافة قسم جديد",
      "add_new_specialization_button": "إضافة اختصاص جديد",
      "create_new_task_button": "إنشاء مهمة جديدة", // Added
      "log_maintenance_button": "تسجيل صيانة",
      "id": "المعرف",
      "contact": "الاتصال",
      "location": "الموقع",
      "role": "الدور",
      "vehicle": "الآلية",
      "number": "الرقم",
      "amount": "المبلغ",
      "title": "العنوان",
      "address": "العنوان",
      "capacity": "القدرة",
      "used": "المستخدم",
      "no_data_available": "لا توجد بيانات متاحة.",
      "resolve": "حل المشكلة",

      "description": "الوصف",
      "import_cycle": "دورة الاستيراد",

      "type_id": "نوع المنتج",
      "unit": "الوحدة",
      "actual_piece_price": "سعر القطعة",

      "required_field": "هذا الحقل مطلوب",
      "invalid_number": "يرجى إدخال رقم صحيح",
    }
  };

  // Get translated string for a given key
  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        key; // Returns key if not found
  }
}

// The delegate required by MaterialApp
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  // List supported locales
  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  // Load translations (instantiate AppLocalizations)
  @override
  Future<AppLocalizations> load(Locale locale) async {
    // This implementation is synchronous because the data is hardcoded
    return AppLocalizations(locale);
  }

  // Indicates whether the delegate should reload if configuration changes
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
