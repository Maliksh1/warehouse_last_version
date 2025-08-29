// lib/models/transfer_request.dart
import 'package:flutter/foundation.dart';

/// انواع الاماكن المسموحة من جهة الباك
enum PlaceType { Warehouse, DistributionCenter }

extension PlaceTypeX on PlaceType {
  String get apiValue => toString().split('.').last;
}

class TransferRequest {
  final PlaceType sourceType;
  final int sourceId;
  final PlaceType destinationType;
  final int destinationId;
  final int productId;
  final int quantity;
  final bool sendVehicles;

  const TransferRequest({
    required this.sourceType,
    required this.sourceId,
    required this.destinationType,
    required this.destinationId,
    required this.productId,
    required this.quantity,
    required this.sendVehicles,
  });

  Map<String, dynamic> toJson() => {
        'source_type': sourceType.apiValue,
        'source_id': sourceId,
        'destination_type': destinationType.apiValue,
        'destination_id': destinationId,
        'product_id': productId,
        'quantity': quantity,
        'send_vehicles': sendVehicles,
      };

  @override
  String toString() => 'TransferRequest(${toJson()})';
}

class TransferResult {
  final bool ok;
  final int statusCode;
  final String message;
  final Map<String, dynamic>? validationErrors;
  const TransferResult({
    required this.ok,
    required this.statusCode,
    required this.message,
    this.validationErrors,
  });

  factory TransferResult.success(
          [String msg = 'successfully', int status = 202]) =>
      TransferResult(ok: true, statusCode: status, message: msg);

  factory TransferResult.fail(int status, String msg,
          [Map<String, dynamic>? errors]) =>
      TransferResult(
          ok: false,
          statusCode: status,
          message: msg,
          validationErrors: errors);
}
