// lib/screens/garage_details_screen.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/garage_item.dart';
import 'package:warehouse/models/vehicle.dart';
import 'package:warehouse/services/garage_api.dart';

class GarageDetailsScreen extends StatefulWidget {
  final GarageItem garage;
  const GarageDetailsScreen({super.key, required this.garage, required int garageId});

  @override
  State<GarageDetailsScreen> createState() => _GarageDetailsScreenState();
}

class _GarageDetailsScreenState extends State<GarageDetailsScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    _vehiclesFuture = GarageApi.fetchVehiclesInGarage(widget.garage.id);
  }

  void _refresh() {
    setState(() {
      _loadVehicles();
    });
  }

  void _importVehicle() {
    // TODO: Navigate to the import vehicle screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم تنفيذ شاشة الاستيراد لاحقًا.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الكراج #${widget.garage.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'تحديث',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'GarageDetailsScreenFAB',
        onPressed: _importVehicle,
        label: const Text('استيراد مركبة'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Handle 404 "no vehicles" gracefully
            if (snapshot.error.toString().contains('Failed to load vehicles')) {
              return const Center(child: Text('لا توجد مركبات في هذا الكراج.'));
            }
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          final vehicles = snapshot.data ?? [];
          if (vehicles.isEmpty) {
            return const Center(child: Text('لا توجد مركبات في هذا الكراج.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      vehicle.sizeOfVehicle == 'big'
                          ? Icons.fire_truck
                          : Icons.directions_car,
                    ),
                  ),
                  title: Text(vehicle.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'السعة: ${vehicle.capacity} • الصلاحية: ${vehicle.expiration}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
