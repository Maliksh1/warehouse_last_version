// lib/screens/garage_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/garage_item.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/screens/garage_details_screen.dart';
import 'package:warehouse/widgets/Dialogs/add_garage_dialog.dart';

class GarageScreen extends ConsumerWidget {
  // --- 1. جعل المتغيرات اختيارية ---
  final String? placeType;
  final int? placeId;

  const GarageScreen({
    super.key,
    this.placeType,
    this.placeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- 2. تحديد ما إذا كانت الشاشة في وضع العرض المفلتر أم العام ---
    final bool isFilteredView = placeType != null && placeId != null;

    // --- 3. اختيار الـ Provider المناسب بناءً على وضع العرض ---
    final garagesAsyncValue = isFilteredView
        ? ref.watch(garageItemsByPlaceProvider(
            {'placeType': placeType!, 'placeId': placeId!}))
        : ref.watch(garageItemsListProvider);

    return Scaffold(
      // --- 4. تعديل العنوان ليكون ديناميكياً ---
      appBar: AppBar(
        title: Text(isFilteredView ? 'Garages' : 'All Garages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (isFilteredView) {
                ref.refresh(garageItemsByPlaceProvider(
                    {'placeType': placeType!, 'placeId': placeId!}));
              } else {
                ref.refresh(garageItemsListProvider);
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
                ref.refresh(garageItemsByPlaceProvider(
                    {'placeType': placeType!, 'placeId': placeId!}));
              } else {
                ref.refresh(garageItemsListProvider);
              }
            },
            child: ListView.builder(
              itemCount: garages.length,
              itemBuilder: (context, index) {
                final garage = garages[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Garage ID: ${garage.id}'),
                    subtitle: Text(
                        'Location: ${garage.location}\nPlace: ${garage.placeType} ${garage.placeId}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
      // --- 5. إظهار زر الإضافة فقط في وضع العرض العام ---
      // floatingActionButton: isFilteredView
      //     ? null
      //     : FloatingActionButton(
      //         heroTag: 'garageScreen',
      //         onPressed: () async {
      //           final success = await showAddGarageDialog(context, ref);
      //           if (context.mounted && success) {
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               const SnackBar(
      //                 content: Text('Garage added successfully!'),
      //                 backgroundColor: Colors.green,
      //               ),
      //             );
      //           }
      //         },
      //         child: const Icon(Icons.add),
      //       ),
    );
  }
}
