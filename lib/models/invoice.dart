enum InvoiceType { purchase, sale } // Added Enum for type

enum InvoiceStatus {
  pending,
  paid,
  overdue,
  cancelled
} // Added Enum for status

class Invoice {
  final String id; // Added unique ID
  final String number; // Invoice number (like "#INV1001")
  final InvoiceType type; // Purchase (from Supplier) or Sale (to Customer)
  final String entityId; // Link to Supplier ID or Customer ID
  final DateTime issueDate; // Date of invoice creation
  final DateTime? dueDate; // Due date (optional, e.g., for sales invoices)
  final DateTime? paymentDate; // Date paid (optional)
  final List<InvoiceItem> items; // List of products/items in the invoice
  final double totalAmount; // Calculated total amount
  final InvoiceStatus status; // Use Enum for status
  final String? notes; // Optional notes

  Invoice({
    required this.id,
    required this.number,
    required this.type,
    required this.entityId,
    required this.issueDate,
    this.dueDate,
    this.paymentDate,
    required this.items, // Initialize with empty list if creating new
    required this.totalAmount, // Should be calculated from items
    this.status = InvoiceStatus.pending, // Default status
    this.notes,
    required double amount,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      number: json['number'],
      type: InvoiceType.values.firstWhere(
          (e) => e.toString() == 'InvoiceType.${json['type']}'), // Parse Enum
      entityId: json['entityId'],
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      items: (json['items'] as List)
          .map((i) => InvoiceItem.fromJson(i))
          .toList(), // Parse list of items
      totalAmount: json['totalAmount'].toDouble(),
      status: InvoiceStatus.values.firstWhere((e) =>
          e.toString() == 'InvoiceStatus.${json['status']}'), // Parse Enum
      notes: json['notes'], amount: 70,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'type': type.toString().split('.').last, // Convert Enum to String
      'entityId': entityId,
      'issueDate': issueDate.toIso8601String(), // Convert DateTime
      'dueDate': dueDate?.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'items':
          items.map((item) => item.toJson()).toList(), // Convert list of items
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last, // Convert Enum to String
      'notes': notes,
    };
  }
}

// Helper model for items within an Invoice
class InvoiceItem {
  final String productId; // Link to Product ID
  final int quantity;
  final double unitPrice; // Price per unit for this item in this invoice

  InvoiceItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      productId: json['productId'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
