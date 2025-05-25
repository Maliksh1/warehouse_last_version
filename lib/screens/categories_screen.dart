import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/providers/data_providers.dart';

// Change to ConsumerWidget to use Riverpod
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  // Hardcoded data removed - will use data from provider

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    final t = AppLocalizations.of(context)!; // Get localization

    // Watch the provider for categories list
    final categoriesAsyncValue = ref.watch(categoriesListProvider);

    // Removed Scaffold and AppBar
    return SingleChildScrollView(
      // Content starts here
      padding: const EdgeInsets.all(16.0), // Added padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Title and Add Button
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Use localization
              Text(t.get('categories'),
                  style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                // Use localization - make sure key exists
                label: Text(t.get('add_new_category_button')),
                onPressed: () {
                  // TODO: Implement Add Category navigation/dialog
                  print("Add Category Button Pressed");
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // TODO: Add Search/Filter (optional for categories)

          const SizedBox(height: 16),

          // Display data based on the async value state
          categoriesAsyncValue.when(
            loading: () => const Center(
                child: CircularProgressIndicator()), // Show loading spinner
            error: (err, stack) => Center(
                child: Text(
                    'Error loading categories: ${err.toString()}')), // Show error message
            data: (categories) {
              if (categories.isEmpty) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                        child: Text(t.get('no_data_available') ??
                            'No data available')), // TODO: Add no_data_available key
                  ),
                );
              }
              // Use ListView.builder for better performance
              return Card(
                // Wrap list in a card
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias, // Clip content
                child: ListView.separated(
                  // Use ListView.separated for dividers
                  shrinkWrap:
                      true, // Must be true when inside SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable its own scrolling
                  itemCount: categories.length, // Use actual data length
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1), // Add dividers
                  itemBuilder: (context, index) {
                    final category =
                        categories[index]; // Use data item (Category model)
                    return ListTile(
                        // ListTile for each category
                        leading: const Icon(Icons.category), // Icon
                        title: Text(category.name), // Category name from model
                        // TODO: Add trailing icons for edit/delete
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: t.get('edit'),
                                onPressed: () {/* TODO */}),
                            IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.redAccent),
                                tooltip: t.get('delete'),
                                onPressed: () {/* TODO */}),
                          ],
                        ));
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
