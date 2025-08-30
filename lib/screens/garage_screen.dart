import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/garage_item.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/screens/garage_details_screen.dart';
import 'package:warehouse/services/garage_api.dart';
import 'package:warehouse/widgets/Dialogs/add_garage_dialog.dart';
import 'package:warehouse/widgets/Dialogs/edit_garage_dialog.dart'; // ✅ إضافة مهمة

class GarageScreen extends ConsumerWidget {
  final String? placeType;
  final int? placeId;

  const GarageScreen({
    super.key,
    this.placeType,
    this.placeId,
  });

  // ✅ دالة مساعدة لتشغيل حوار الإضافة
  void _addGarage(BuildContext context, WidgetRef ref) async {
    final success = await showAddGarageDialog(
      context,
      ref,
      preselectedPlaceType: placeType,
      preselectedPlaceId: placeId,
    );

    if (context.mounted && (success ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Garage added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✅ دالة مساعدة لتشغيل حوار التعديل
  void _editGarage(BuildContext context, WidgetRef ref, GarageItem garage) async {
     final success = await showEditGarageDialog(context, ref, garage);
     
     if (context.mounted && (success ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Garage updated successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
     }
  }


  // ✅ دالة مساعدة لتشغيل حوار الحذف
  void _deleteGarage(BuildContext context, WidgetRef ref, GarageItem garage) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete Garage ID: ${garage.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await GarageApi.deleteGarage(garage.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Garage deleted successfully!' : GarageApi.lastErrorMessage ?? 'Failed to delete garage.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
          if (placeType != null && placeId != null) {
              ref.invalidate(garageItemsByPlaceProvider(GarageParameter(placeType: placeType!, placeId: placeId!)));
          } else {
              ref.invalidate(garageItemsListProvider);
          }
      }
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFilteredView = placeType != null && placeId != null;

    final garagesAsyncValue = isFilteredView
        ? ref.watch(garageItemsByPlaceProvider(
            GarageParameter(placeType: placeType!, placeId: placeId!)))
        : ref.watch(garageItemsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isFilteredView ? 'Garages' : 'All Garages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (isFilteredView) {
                ref.invalidate(garageItemsByPlaceProvider(
                    GarageParameter(placeType: placeType!, placeId: placeId!)));
              } else {
                ref.invalidate(garageItemsListProvider);
              }
            },
          ),
        ],
      ),
      body: garagesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (garages) {
          if (garages.isEmpty) {
            return const Center(child: Text('No garages found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              if (isFilteredView) {
                 ref.invalidate(garageItemsByPlaceProvider(
                    GarageParameter(placeType: placeType!, placeId: placeId!)));
              } else {
                ref.invalidate(garageItemsListProvider);
              }
            },
            child: ListView.builder(
              itemCount: garages.length,
              itemBuilder: (context, index) {
                final garage = garages[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.warehouse_rounded),
                    title: Text('Garage ID: ${garage.id}'),
                    subtitle: Text(
                        'Vehicle Size: ${garage.sizeOfVehicle}\nCapacity: ${garage.currentVehicles} / ${garage.maxCapacity}'),
                    // ✅ ---  هنا التعديل الرئيسي ---
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          tooltip: 'Edit Garage',
                          onPressed: () => _editGarage(context, ref, garage),
                        ),
                        IconButton(
                           icon: const Icon(Icons.delete_outline, color: Colors.red),
                           tooltip: 'Delete Garage',
                           onPressed: () => _deleteGarage(context, ref, garage),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GarageDetailsScreen(
                            garageId: garage.id,
                            garage: garage,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addGarageFab',
        onPressed: () => _addGarage(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

