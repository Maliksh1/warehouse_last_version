import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/providers/locale_provider.dart';

// A placeholder screen for the "Create Transport Task" form
class CreateTransportTaskScreen extends ConsumerWidget {
  const CreateTransportTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    // Get the notifier to change the page back
    final selectedPageIndexNotifier =
        ref.read(selectedPageIndexProvider.notifier);

    return SingleChildScrollView(
      // Make screen scrollable
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Title and Cancel button
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.get('create_new_task'),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium), // Use localization key
              TextButton(
                // Cancel button to go back
                onPressed: () {
                  // Navigate back to the Dashboard Overview (index 0) or Transport Tasks list (index 11)
                  selectedPageIndexNotifier.state =
                      0; // Go back to dashboard overview
                  // selectedPageIndexNotifier.state = 11; // Or go back to tasks list
                },
                child: Text(t.get('cancel') ?? 'Cancel'), // Use localization
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TODO: Add your actual form fields here
          // Example placeholders:
          const TextField(
            decoration: InputDecoration(
                labelText: 'From Location (ID/Name)',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
                labelText: 'To Location (ID/Name)',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
                labelText: 'Vehicle (ID/License)',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
                labelText: 'Driver (Employee ID/Name)',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Text('Items to Transport',
              style: Theme.of(context).textTheme.titleMedium),
          // TODO: Add UI to select products and quantities
          const SizedBox(height: 8),
          Card(
              child: Container(
                  height: 100,
                  child: Center(
                      child: Text('Product/Quantity Selection Placeholder')))),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity, // Make button full width
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement Save New Task logic
                print("Save New Task Button Pressed");
                // After saving, navigate back
                selectedPageIndexNotifier.state =
                    11; // Go to Transport Tasks list after saving
              },
              child: Text(t.get('create_new_task')), // Use localization key
            ),
          ),
        ],
      ),
    );
  }
}
