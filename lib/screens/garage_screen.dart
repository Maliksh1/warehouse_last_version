// lib/screens/garage_screen.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/garage_item.dart';
import 'package:warehouse/screens/garage_details_screen.dart';
import 'package:warehouse/services/garage_api.dart';

class GarageScreen extends StatefulWidget {
  final String? placeType;
  final int? placeId;

  const GarageScreen({
    super.key,
    this.placeType,
    this.placeId,
  });

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  late Future<List<GarageItem>> _garagesFuture;
  bool _isGeneralView = false;

  @override
  void initState() {
    super.initState();
    _isGeneralView = (widget.placeType == null || widget.placeId == null);
    _loadGarages();
  }

  void _loadGarages() {
    if (_isGeneralView) {
      _garagesFuture = GarageApi.fetchAllGarages();
    } else {
      _garagesFuture =
          GarageApi.fetchGaragesForPlace(widget.placeType!, widget.placeId!);
    }
  }

  void _refresh() {
    setState(() {
      _loadGarages();
    });
  }

  void _addGarage() async {
    if (_isGeneralView) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('لا يمكن إضافة كراج من هذه الشاشة العامة.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddEditGarageDialog(
        placeType: widget.placeType!,
        placeId: widget.placeId!,
      ),
    );
    if (result == true) {
      _refresh();
    }
  }

  void _editGarage(GarageItem garage) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddEditGarageDialog(
        garage: garage,
        placeType: garage.existableType,
        placeId: garage.existableId,
      ),
    );
    if (result == true) {
      _refresh();
    }
  }

  void _deleteGarage(GarageItem garage) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الكراج رقم ${garage.id}؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await GarageApi.deleteGarage(garage.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'تم حذف الكراج'
              : (GarageApi.lastErrorMessage ?? 'فشل الحذف')),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
        if (success) _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isGeneralView ? 'كل الكراجات' : 'الكراجات',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'تحديث',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_garage',
        onPressed: _isGeneralView ? null : _addGarage,
        backgroundColor: _isGeneralView ? Colors.grey : null,
        label: const Text('إضافة كراج'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<GarageItem>>(
        future: _garagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          final garages = snapshot.data ?? [];
          if (garages.isEmpty) {
            return const Center(child: Text('لا توجد كراجات.'));
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: garages.length,
              itemBuilder: (context, index) {
                final garage = garages[index];
                return _GarageCard(
                  garage: garage,
                  isGeneralView: _isGeneralView,
                  onEdit: () => _editGarage(garage),
                  onDelete: () => _deleteGarage(garage),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GarageDetailsScreen(garage: garage),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _GarageCard extends StatelessWidget {
  final GarageItem garage;
  final bool isGeneralView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _GarageCard({
    required this.garage,
    required this.isGeneralView,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBig = garage.sizeOfVehicle.toLowerCase() == 'big';
    final usage = garage.maxCapacity > 0
        ? (garage.currentVehicles / garage.maxCapacity).clamp(0.0, 1.0)
        : 0.0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('كراج #${garage.id}',
                      style: Theme.of(context).textTheme.titleLarge),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('تعديل')),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                            leading:
                                Icon(Icons.delete_outline, color: Colors.red),
                            title: Text('حذف')),
                      ),
                    ],
                  ),
                ],
              ),
              if (isGeneralView)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                      'الموقع: ${garage.existableType} #${garage.existableId}',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              const SizedBox(height: 8),
              Chip(
                avatar: Icon(isBig
                    ? Icons.fire_truck_outlined
                    : Icons.directions_car_outlined),
                label: Text(isBig ? 'مركبات كبيرة' : 'مركبات متوسطة'),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: usage,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Text('الإشغال: ${garage.currentVehicles}/${garage.maxCapacity}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddEditGarageDialog extends StatefulWidget {
  final GarageItem? garage;
  final String placeType;
  final int placeId;

  const _AddEditGarageDialog(
      {this.garage, required this.placeType, required this.placeId});

  @override
  State<_AddEditGarageDialog> createState() => _AddEditGarageDialogState();
}

class _AddEditGarageDialogState extends State<_AddEditGarageDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSize = 'medium';
  late TextEditingController _capacityCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.garage?.sizeOfVehicle ?? 'medium';
    _capacityCtrl = TextEditingController(
        text: widget.garage?.maxCapacity.toString() ?? '');
  }

  @override
  void dispose() {
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final payload = {
      "size_of_vehicle": _selectedSize,
      "max_capacity": int.parse(_capacityCtrl.text),
      "existable_type": widget.placeType,
      "existable_id": widget.placeId,
    };

    bool success;
    if (widget.garage != null) {
      payload['garage_id'] = widget.garage!.id;
      success = await GarageApi.editGarage(payload);
    } else {
      success = await GarageApi.createGarage(payload);
    }

    if (mounted) {
      setState(() => _submitting = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(GarageApi.lastErrorMessage ?? 'فشل العملية'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.garage == null ? 'إضافة كراج جديد' : 'تعديل الكراج'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSize,
              decoration: const InputDecoration(
                  labelText: 'حجم المركبات', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'medium', child: Text('متوسط')),
                DropdownMenuItem(value: 'big', child: Text('كبير')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedSize = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityCtrl,
              decoration: const InputDecoration(
                  labelText: 'السعة القصوى', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.trim().isEmpty || int.tryParse(v) == null)
                      ? 'أدخل رقماً صحيحاً'
                      : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context),
            child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: Text(_submitting ? 'جارٍ الحفظ...' : 'حفظ'),
        ),
      ],
    );
  }
}
