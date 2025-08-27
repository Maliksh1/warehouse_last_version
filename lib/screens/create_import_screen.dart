// lib/screens/create_import_screen.dart
import 'package:flutter/material.dart';

import 'package:warehouse/screens/wizards/storage_media_import_wizard.dart';

// This is now the main hub for all import operations.
class CreateImportScreen extends StatelessWidget {
  const CreateImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Import'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildImportOptionCard(
            context: context,
            icon: Icons.widgets_outlined,
            title: 'Import Storage Media',
            subtitle: 'Start the process to import new storage units.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const StorageMediaImportWizard(),
                ),
              );
            },
          ),
          _buildImportOptionCard(
            context: context,
            icon: Icons.inventory_2_outlined,
            title: 'Import Products',
            subtitle: 'Start the process to import products from a supplier.',
            onTap: () {
              // Placeholder for the future product import wizard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Product import wizard is coming soon!')),
              );
            },
          ),
          _buildImportOptionCard(
            context: context,
            icon: Icons.local_shipping_outlined,
            title: 'Import Vehicles',
            subtitle: 'Start the process to import new vehicles.',
            onTap: () {
              // Placeholder for the future vehicle import wizard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Vehicle import wizard is coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for a consistent card design
  Widget _buildImportOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
