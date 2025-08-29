// lib/screens/wizards/vehicle_import_wizard.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/imported_vehicle_info.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/import_api.dart';

// --- WIZARD CONTAINER ---
class VehicleImportWizard extends ConsumerStatefulWidget {
  const VehicleImportWizard({super.key});

  @override
  ConsumerState<VehicleImportWizard> createState() =>
      _VehicleImportWizardState();
}

class _VehicleImportWizardState extends ConsumerState<VehicleImportWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Supplier? _selectedSupplier;
  String? _location;
  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void _previousPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final selectedVehicles = ref.read(vehicleImportWizardProvider);

    // Basic validation
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a supplier.'),
        backgroundColor: Colors.orange,
      ));
      setState(() => _isSubmitting = false);
      return;
    }
    if (selectedVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add at least one vehicle.'),
        backgroundColor: Colors.orange,
      ));
      setState(() => _isSubmitting = false);
      return;
    }
    if (_location == null || _latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter location details.'),
        backgroundColor: Colors.orange,
      ));
      setState(() => _isSubmitting = false);
      return;
    }

    final success = await ImportApi.createPendingVehicleImport(
        supplier: _selectedSupplier!,
        location: _location!,
        latitude: _latitude!,
        longitude: _longitude!,
        vehicles: selectedVehicles);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Vehicle Operation Submitted Successfully!'
            : ImportApi.lastErrorMessage ?? 'Failed to submit operation!'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        ref.invalidate(vehicleImportWizardProvider);
        ref.read(allPendingOperationsProvider.notifier).fetchOperations();
        Navigator.of(context).pop();
      } else {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Step1SelectSupplier(onSelected: (supplier) {
        setState(() => _selectedSupplier = supplier);
        _nextPage();
      }),
      _Step2ManageVehicles(
        supplier: _selectedSupplier,
        location: _location,
        onLocationChanged: (loc, lat, lon) {
          setState(() {
            _location = loc;
            _latitude = lat;
            _longitude = lon;
          });
        },
        onSubmit: _submit,
        isSubmitting: _isSubmitting,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Import Vehicles (Step ${_currentPage + 1})'),
        leading: _currentPage > 0 && !_isSubmitting
            ? IconButton(
                icon: const Icon(Icons.arrow_back), onPressed: _previousPage)
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: pages,
      ),
    );
  }
}

// --- STEP 1: SELECT SUPPLIER ---
class _Step1SelectSupplier extends ConsumerWidget {
  final Function(Supplier) onSelected;
  const _Step1SelectSupplier({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersListProvider);
    return suppliersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (suppliers) => ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(supplier.name),
            subtitle: Text(supplier.country),
            onTap: () => onSelected(supplier),
          );
        },
      ),
    );
  }
}

// --- STEP 2: MANAGE VEHICLES ---
class _Step2ManageVehicles extends ConsumerWidget {
  final Supplier? supplier;
  final String? location;
  final Function(String, double, double) onLocationChanged;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  const _Step2ManageVehicles({
    required this.supplier,
    required this.location,
    required this.onLocationChanged,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (supplier == null) {
      return const Center(child: Text('Please select a supplier first.'));
    }

    final selectedVehicles = ref.watch(vehicleImportWizardProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
        onPressed: () => _showAddVehicleDialog(context, ref, supplier!),
      ),
      body: Column(
        children: [
          _LocationInput(
            initialLocation: location,
            onLocationChanged: onLocationChanged,
          ),
          Expanded(
            child: selectedVehicles.isEmpty
                ? const Center(child: Text('No vehicles added yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: selectedVehicles.length,
                    itemBuilder: (context, index) {
                      return _ImportedVehicleCard(
                          vehicleInfo: selectedVehicles[index]);
                    },
                  ),
          ),
          if (selectedVehicles.isNotEmpty && location != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ))
                    : const Icon(Icons.send),
                label: Text(
                    isSubmitting ? 'Submitting...' : 'Submit Import Operation'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: isSubmitting ? null : onSubmit,
              ),
            )
        ],
      ),
    );
  }

  void _showAddVehicleDialog(
      BuildContext context, WidgetRef ref, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final vehiclesAsync = ref.watch(vehiclesListProvider);
          return AlertDialog(
            title: const Text('Add Vehicle'),
            content: SingleChildScrollView(
              child: _AddVehicleForm(
                onSubmit: (vehicle) {
                  ref
                      .read(vehicleImportWizardProvider.notifier)
                      .addVehicle(vehicle);
                  Navigator.of(context).pop();
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'))
            ],
          );
        },
      ),
    );
  }
}

// --- WIDGET FOR LOCATION INPUT ---
class _LocationInput extends ConsumerStatefulWidget {
  final String? initialLocation;
  final Function(String, double, double) onLocationChanged;
  const _LocationInput(
      {required this.initialLocation, required this.onLocationChanged});

  @override
  ConsumerState<_LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends ConsumerState<_LocationInput> {
  late final TextEditingController _locationController;
  late final TextEditingController _latController;
  late final TextEditingController _lonController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.initialLocation);
    _latController = TextEditingController();
    _lonController = TextEditingController();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
            onChanged: (val) => widget.onLocationChanged(
                val,
                double.tryParse(_latController.text) ?? 0,
                double.tryParse(_lonController.text) ?? 0),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => widget.onLocationChanged(
                      _locationController.text,
                      double.tryParse(val) ?? 0,
                      double.tryParse(_lonController.text) ?? 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _lonController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => widget.onLocationChanged(
                      _locationController.text,
                      double.tryParse(_latController.text) ?? 0,
                      double.tryParse(val) ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WIDGET FOR ADDING A SINGLE VEHICLE ---
class _AddVehicleForm extends ConsumerStatefulWidget {
  final Function(ImportedVehicleInfo) onSubmit;
  const _AddVehicleForm({required this.onSubmit});

  @override
  ConsumerState<_AddVehicleForm> createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends ConsumerState<_AddVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  // ✅ استخدام TextEditingController لجميع الحقول النصية
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _readinessController = TextEditingController();
  final _expirationController = TextEditingController();
  final _productedInController = TextEditingController();

  String? _sizeOfVehicle;
  Product? _selectedProduct;
  dynamic _selectedPlace; // ✅ متغير جديد لتخزين الكائن الكامل

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _readinessController.dispose();
    _expirationController.dispose();
    _productedInController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newVehicle = ImportedVehicleInfo(
        name: _nameController.text,
        expiration: _expirationController.text,
        productedIn: _productedInController.text,
        readiness: double.tryParse(_readinessController.text) ?? 0,
        sizeOfVehicle: _sizeOfVehicle!,
        capacity: int.tryParse(_capacityController.text) ?? 0,
        product: _selectedProduct,
        placeType:
            _selectedPlace is Warehouse ? 'Warehouse' : 'DistributionCenter',
        placeId:
            _selectedPlace is Warehouse ? _selectedPlace.id : _selectedPlace.id,
        placeName: _selectedPlace is Warehouse
            ? _selectedPlace.name
            : _selectedPlace.name,
        productName: _selectedProduct?.name,
      );
      widget.onSubmit(newVehicle);
    }
  }

  // ✅ دالة مساعدة لاختيار التاريخ
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsListProvider);
    final placesAsync = ref.watch(placesListProvider);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Vehicle Name'),
            validator: (val) => val!.isEmpty ? 'Name is required' : null,
          ),
          TextFormField(
            controller: _capacityController,
            decoration: const InputDecoration(labelText: 'Capacity'),
            keyboardType: TextInputType.number,
            validator: (val) =>
                int.tryParse(val!) == null ? 'Invalid capacity' : null,
          ),
          TextFormField(
            controller: _readinessController,
            decoration: const InputDecoration(labelText: 'Readiness'),
            keyboardType: TextInputType.number,
            validator: (val) =>
                double.tryParse(val!) == null ? 'Invalid readiness' : null,
          ),
          // ✅ استخدام الدالة المساعدة لحقول التاريخ
          TextFormField(
            controller: _expirationController,
            decoration: const InputDecoration(
                labelText: 'Expiration Date',
                suffixIcon: Icon(Icons.calendar_today)),
            readOnly: true,
            onTap: () => _selectDate(context, _expirationController),
            validator: (val) =>
                val!.isEmpty ? 'Expiration date is required' : null,
          ),
          TextFormField(
            controller: _productedInController,
            decoration: const InputDecoration(
                labelText: 'Production Date',
                suffixIcon: Icon(Icons.calendar_today)),
            readOnly: true,
            onTap: () => _selectDate(context, _productedInController),
            validator: (val) =>
                val!.isEmpty ? 'Production date is required' : null,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Size of Vehicle'),
            value: _sizeOfVehicle,
            items: ['big', 'medium']
                .map((size) => DropdownMenuItem(value: size, child: Text(size)))
                .toList(),
            onChanged: (val) => setState(() => _sizeOfVehicle = val),
            validator: (val) => val == null ? 'Size is required' : null,
          ),
          productsAsync.when(
            data: (products) => DropdownButtonFormField<Product>(
              decoration: const InputDecoration(labelText: 'Product'),
              value: _selectedProduct,
              items: products
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedProduct = val),
              validator: (val) => val == null ? 'Product is required' : null,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => Text('Error loading products: $e'),
          ),
          placesAsync.when(
            data: (places) => DropdownButtonFormField<dynamic>(
              decoration: const InputDecoration(labelText: 'Place'),
              // ✅ إصلاح: استخدام متغير الحالة
              value: _selectedPlace,
              items: places.map((place) {
                String placeName = place is Warehouse
                    ? place.name
                    : (place as DistributionCenter).name;
                String placeType =
                    place is Warehouse ? 'Warehouse' : 'DistributionCenter';
                return DropdownMenuItem(
                  value: place,
                  child: Text('$placeName ($placeType)'),
                );
              }).toList(),
              // ✅ إصلاح: تحديث متغير الحالة عند الاختيار
              onChanged: (val) => setState(() => _selectedPlace = val),
              validator: (val) => val == null ? 'Place is required' : null,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => Text('Error loading places: $e'),
          ),

          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }
}

// --- CARD FOR EACH IMPORTED VEHICLE ---
class _ImportedVehicleCard extends ConsumerWidget {
  final ImportedVehicleInfo vehicleInfo;
  const _ImportedVehicleCard({required this.vehicleInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(vehicleInfo.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Size: ${vehicleInfo.sizeOfVehicle} | Capacity: ${vehicleInfo.capacity}'),
            Text(
                'Location: ${vehicleInfo.placeName} (${vehicleInfo.placeType})'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => ref
              .read(vehicleImportWizardProvider.notifier)
              .removeVehicle(vehicleInfo),
        ),
      ),
    );
  }
}
