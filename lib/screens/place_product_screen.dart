// lib/screens/place_products_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/providers/data_providers.dart';

// --- 1. تحويل الويدجت إلى ConsumerStatefulWidget ---
class PlaceProductsScreen extends ConsumerStatefulWidget {
  final String placeType;
  final int placeId;
  final String placeName;

  const PlaceProductsScreen({
    super.key,
    required this.placeType,
    required this.placeId,
    required this.placeName,
  });

  @override
  ConsumerState<PlaceProductsScreen> createState() =>
      _PlaceProductsScreenState();
}

class _PlaceProductsScreenState extends ConsumerState<PlaceProductsScreen> {
  // --- 2. تعريف متغير لتخزين كائن المتغيرات ---
  late final PlaceParameter params;

  @override
  void initState() {
    super.initState();
    // --- 3. إنشاء كائن المتغيرات مرة واحدة فقط عند تهيئة الشاشة ---
    params = PlaceParameter(
      placeType: widget.placeType,
      placeId: widget.placeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- 4. استخدام نفس الكائن 'params' في كل مرة يتم فيها إعادة البناء ---
    final productsAsyncValue =
        ref.watch(productsByPlaceProvider(params as Map<String, dynamic>));

    return Scaffold(
      appBar: AppBar(
        title: Text('Products in ${widget.placeName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(
                productsByPlaceProvider(params as Map<String, dynamic>)),
          ),
        ],
      ),
      body: productsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('An error occurred: $err')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products found in this location.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(
                productsByPlaceProvider(params as Map<String, dynamic>)),
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (ctx, index) {
                final product = products[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(product.id.toString()),
                    ),
                    title: Text(product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Type: ${product.typeId}'),
                    trailing: Text(
                      'Quantity: ${product.quantity}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
