// search_filter.dart
/// تمثيل فلتر البحث كما يتوقعه الباك (أسماء موديلات Laravel داخل app/Models).
class SearchFilter {
  final String key;   // يُرسل للباك (Product, Warehouse, Transfer, ...)
  final String label; // اسم للعرض في الواجهة

  const SearchFilter(this.key, this.label);

  static const List<SearchFilter> defaults = [
    SearchFilter('Containers_type', 'أنواع الحاويات'),
    SearchFilter('Continer_transfer', 'نقل الحاويات'),
    SearchFilter('DistributionCenter', 'مركز توزيع'),
    SearchFilter('Employe', 'موظف'),
    SearchFilter('Favorite', 'مفضلة'),
    SearchFilter('Garage', 'كراج'),
    SearchFilter('Imp_continer_product', 'منتج في حاوية واردة'),
    SearchFilter('Import_op_container', 'حاوية واردة'),
    SearchFilter('Import_op_storage_md', 'وسيط تخزين وارد'),
    SearchFilter('Import_operation', 'عملية توريد'),
    SearchFilter('Import_operation_product', 'منتج عملية توريد'),
    SearchFilter('Invoice', 'فاتورة'),
    SearchFilter('Job', 'وظيفة'),
    SearchFilter('MovableProduct', 'منتج متحرك'),
    SearchFilter('Posetions_on_section', 'مواضع على قسم'),
    SearchFilter('Positions_on_sto_m', 'مواضع على مخزن'),
    SearchFilter('Product', 'منتج'),
    SearchFilter('Request_detail', 'تفصيل طلب'),
    SearchFilter('Requests', 'طلبات'),
    SearchFilter('Section', 'قسم'),
    SearchFilter('Sell_detail', 'تفصيل بيع'),
    SearchFilter('Specialization', 'تخصص'),
    SearchFilter('Storage_media', 'وسيط تخزين'),
    SearchFilter('Supplier', 'مورد'),
    SearchFilter('Supplier_Details', 'تفاصيل مورد'),
    SearchFilter('Transfer', 'نقل'),
    SearchFilter('Transfer_detail', 'تفصيل نقل'),
    SearchFilter('User', 'مستخدم'),
    SearchFilter('Vehicle', 'مركبة'),
    SearchFilter('Violation', 'مخالفة'),
    SearchFilter('Warehouse', 'مستودع'),
    SearchFilter('container_movments', 'حركات الحاوية'),
    SearchFilter('reject_details', 'تفاصيل رفض'),
    SearchFilter('reserved_details', 'تفاصيل حجز'),
  ];

  static SearchFilter? byKey(String key) {
    try { return defaults.firstWhere((f) => f.key == key); } catch (_) { return null; }
  }
}
