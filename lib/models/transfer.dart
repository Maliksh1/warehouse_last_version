// transfer.dart
import 'package:flutter/foundation.dart';

/// اتجاه السجل
enum TransferLogType { incoming, outgoing }

/// نموذج سجل نقل كما يرجع من الباك
class TransferItem {
  final int id;
  final String? status; // contained | return | (أخرى)
  final String? dateOfResiving;  // قد تكون null
  final String? dateOfFinishing; // قد تكون null
  final Map<String, dynamic>? sourceable;
  final Map<String, dynamic>? destinationable;

  const TransferItem({
    required this.id,
    this.status,
    this.dateOfResiving,
    this.dateOfFinishing,
    this.sourceable,
    this.destinationable,
  });

  factory TransferItem.fromJson(Map<String, dynamic> json) {
    return TransferItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString(),
      dateOfResiving: json['date_of_resiving']?.toString(),
      dateOfFinishing: json['date_of_finishing']?.toString(),
      sourceable: json['sourceable'] is Map<String, dynamic> ? json['sourceable'] as Map<String, dynamic> : null,
      destinationable: json['destinationable'] is Map<String, dynamic> ? json['destinationable'] as Map<String, dynamic> : null,
    );
  }

  String? get counterpartName {
    // لو incoming: يكون لدينا sourceable
    // لو outgoing: لدينا destinationable
    final srcName = sourceable?['name']?.toString();
    final dstName = destinationable?['name']?.toString();
    // أعد أي اسم متاح
    return srcName ?? dstName;
  }
}

/// حاوية المجموعات الثلاث
class TransferBuckets {
  final List<TransferItem> live;
  final List<TransferItem> archiv;
  final List<TransferItem> wait;
  const TransferBuckets({required this.live, required this.archiv, required this.wait});
}
