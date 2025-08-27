// lib/screens/employee_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse/models/employee.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailsScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee.name),
        actions: [
          // The Edit and Delete buttons are now here
          IconButton(
            tooltip: 'تعديل',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Pop with a result to trigger the edit dialog
              Navigator.pop(context, 'edit');
            },
          ),
          IconButton(
            tooltip: 'حذف',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Pop with a result to trigger the delete confirmation
              Navigator.pop(context, 'delete');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const Divider(height: 32),
                _buildDetailRow(
                    Icons.badge_outlined, 'الاختصاص', employee.specialization),
                _buildDetailRow(
                    Icons.phone_outlined, 'رقم الجوال', employee.phoneNumber),
                _buildDetailRow(
                    Icons.email_outlined, 'البريد الإلكتروني', employee.email),
                _buildDetailRow(
                    Icons.attach_money_outlined, 'الراتب', employee.salary),
                _buildDetailRow(
                    Icons.public_outlined, 'الدولة', employee.country),
                _buildDetailRow(Icons.access_time_outlined, 'وقت بدء العمل',
                    employee.startTime),
                _buildDetailRow(
                    Icons.timer_outlined, 'ساعات العمل', employee.workHours),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          child: Icon(Icons.person, size: 30),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (employee.specializationId != null)
              Text(
                'ID: ${employee.id} • Specialization ID: ${employee.specializationId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // Don't show empty rows
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
