// lib/widgets/send_products_card.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/transfer_request.dart';
import 'package:warehouse/services/transfer_api.dart';
import 'package:warehouse/services/warehouse_api.dart';
import 'package:warehouse/services/distribution_center_api.dart';
import 'package:warehouse/services/product_api.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/product.dart';

/// بطاقة إرسال المنتجات لاستخدامها داخل أي شاشة
/// - تسمح بتغيير نوع/هوية المصدر حتى لو تم تمرير قيم افتراضية
/// - تصميم أكثر احترافية ووضوحًا
class SendProductsCard extends StatefulWidget {
  final PlaceType? initialSourceType;
  final int? initialSourceId;

  const SendProductsCard({
    super.key,
    this.initialSourceType,
    this.initialSourceId,
  });

  @override
  State<SendProductsCard> createState() => _SendProductsCardState();
}

class _SendProductsCardState extends State<SendProductsCard> {
  final _formKey = GlobalKey<FormState>();

  PlaceType? _sourceType;
  int? _sourceId;
  PlaceType _destinationType = PlaceType.DistributionCenter;
  int? _destinationId;
  int? _productId;
  int _quantity = 0;
  bool _sendVehicles = false;

  List<Warehouse> _warehouses = [];
  List<DistributionCenter> _centers = [];
  List<Product> _products = [];

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _sourceType = widget.initialSourceType ?? PlaceType.Warehouse;
    _sourceId = widget.initialSourceId;
    _initData();
  }

  Future<void> _initData() async {
    try {
      final warehouses = await WarehouseApi.fetchAllWarehouses();
      final centers = await DistributionCenterApi.fetchAllDistributionCenters();
      final products = await ProductApi.fetchAllProducts();

      setState(() {
        _warehouses = warehouses;
        _centers = centers;
        _products = products;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Init data failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل البيانات: $e')),
        );
      }
    }
  }

  List<DropdownMenuItem<int>> _itemsFor(PlaceType? type) {
    final t = type ?? PlaceType.Warehouse;
    if (t == PlaceType.Warehouse) {
      return _warehouses
          .map((w) => DropdownMenuItem<int>(
              value: w.id, child: Text('${w.name} (ID: ${w.id})')))
          .toList();
    } else {
      return _centers
          .map((c) => DropdownMenuItem<int>(
              value: c.id, child: Text('${c.name} (ID: ${c.id})')))
          .toList();
    }
  }

  Widget _typeChips({
    required PlaceType? value,
    required ValueChanged<PlaceType> onChanged,
    required String warehouseLabel,
    required String centerLabel,
  }) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text(warehouseLabel),
          selected: value == PlaceType.Warehouse,
          onSelected: (_) => onChanged(PlaceType.Warehouse),
        ),
        ChoiceChip(
          label: Text(centerLabel),
          selected: value == PlaceType.DistributionCenter,
          onSelected: (_) => onChanged(PlaceType.DistributionCenter),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.4)),
              SizedBox(width: 12),
              Text('جارِ التحميل...'),
            ],
          ),
        ),
      );
    }

    final divider = const SizedBox(height: 16);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_shipping_outlined),
                  SizedBox(width: 8),
                  Text('إرسال منتجات',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('اختر المصدر والوجهة والمنتج والكمية، ثم اضغط إرسال.'),
              divider,
              // المصدر
              Text('المصدر', style: Theme.of(context).textTheme.subtitle1),
              const SizedBox(height: 8),
              _typeChips(
                value: _sourceType,
                onChanged: (v) => setState(() {
                  _sourceType = v;
                  _sourceId = null;
                }),
                warehouseLabel: 'مستودع',
                centerLabel: 'مركز توزيع',
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _sourceId,
                decoration: const InputDecoration(
                  labelText: 'اختر المصدر',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _itemsFor(_sourceType),
                onChanged: (v) => setState(() => _sourceId = v),
                validator: (v) => v == null ? 'اختر المصدر' : null,
              ),
              divider,
              // الوجهة
              Text('الوجهة', style: Theme.of(context).textTheme.subtitle1),
              const SizedBox(height: 8),
              _typeChips(
                value: _destinationType,
                onChanged: (v) => setState(() {
                  _destinationType = v;
                  _destinationId = null;
                }),
                warehouseLabel: 'مستودع',
                centerLabel: 'مركز توزيع',
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _destinationId,
                decoration: const InputDecoration(
                  labelText: 'اختر الوجهة',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _itemsFor(_destinationType),
                onChanged: (v) => setState(() => _destinationId = v),
                validator: (v) => v == null ? 'اختر الوجهة' : null,
              ),
              divider,
              // المنتج والكمية
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _productId,
                      decoration: const InputDecoration(
                        labelText: 'المنتج',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _products
                          .map((p) => DropdownMenuItem<int>(
                                value: int.tryParse(p.id) ?? -1,
                                child: Text(p.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _productId = v),
                      validator: (v) =>
                          (v == null || v <= 0) ? 'اختر المنتج' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _quantity > 0 ? '$_quantity' : '',
                      decoration: const InputDecoration(
                        labelText: 'الكمية (عدد القطع)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (t) => _quantity = int.tryParse(t) ?? 0,
                      validator: (t) {
                        final q = int.tryParse(t ?? '');
                        if (q == null || q <= 0) return 'ادخل كمية صحيحة';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _sendVehicles,
                onChanged: (v) => setState(() => _sendVehicles = v ?? false),
                title: const Text('إرسال مع المركبات (إن وُجدت)'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              // زر الإرسال
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: const Text('إرسال'),
                  onPressed: _submitting ? null : _onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sourceType == null ||
        _sourceId == null ||
        _destinationId == null ||
        _productId == null) return;

    // منع إرسال لنفس المكان تمامًا
    if (_sourceType == _destinationType && _sourceId == _destinationId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن أن تكون الوجهة هي نفس المصدر')),
      );
      return;
    }

    final req = TransferRequest(
      sourceType: _sourceType!,
      sourceId: _sourceId!,
      destinationType: _destinationType,
      destinationId: _destinationId!,
      productId: _productId!,
      quantity: _quantity,
      sendVehicles: _sendVehicles,
    );

    setState(() => _submitting = true);
    final result = await TransferApi.sendProducts(req);
    setState(() => _submitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result.message)));

    if (!result.ok && result.validationErrors != null) {
      debugPrint('Validation errors: ${result.validationErrors}');
    }

    if (result.ok) {
      // يمكنك هنا تحديث القوائم أو الإغلاق
      // Navigator.maybePop(context);
    }
  }
}
