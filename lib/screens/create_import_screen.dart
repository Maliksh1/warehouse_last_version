// lib/screens/create_import_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/screens/pending_import_screen.dart';
import 'package:warehouse/screens/wizards/product_import_wizard.dart';
import 'package:warehouse/screens/wizards/storage_media_import_wizard.dart';

class CreateImportScreen extends ConsumerWidget {
  const CreateImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق المستودعات'),
        actions: [
          // زر لعرض العمليات المعلقة
          IconButton(
            tooltip: 'Pending Operations',
            icon: const Icon(Icons.pending_actions_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PendingImportsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Create New Import',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // --- 1. كارد استيراد وسائط التخزين ---
          _ImportActionCard(
            title: 'Import Storage Media',
            subtitle: 'Start the process to import new storage units.',
            icon: Icons.widgets_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StorageMediaImportWizard(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // --- 2. كارد استيراد المنتجات (تم الربط) ---
          _ImportActionCard(
            title: 'Import Products',
            subtitle: 'Start the process to import products from a supplier.',
            icon: Icons.inventory_2_outlined,
            onTap: () {
              // ✅ ---  هنا تم الربط ---
              // عند الضغط، يتم فتح معالج استيراد المنتجات الجديد
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProductImportWizard(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // --- 3. كارد استيراد المركبات (مستقبلي) ---
          _ImportActionCard(
            title: 'Import Vehicles',
            subtitle: 'Start the process to import new vehicles.',
            icon: Icons.local_shipping_outlined,
            onTap: () {
              // يمكنك إضافة معالج استيراد المركبات هنا في المستقبل
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vehicle import feature is coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ويدجت احترافي وموحد لشكل الكارد
class _ImportActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ImportActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
