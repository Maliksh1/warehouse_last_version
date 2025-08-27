// lib/models/supplier.dart
import 'dart:convert';

class Supplier {
  final int id;
  final String name;
  final String country;
  final String identifier;
  final String communicationWay;
  final String? createdAt;
  final String? updatedAt;

  Supplier({
    required this.id,
    required this.name,
    required this.country,
    required this.identifier,
    required this.communicationWay,
    this.createdAt,
    this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      identifier: json['identifier'],
      // The backend uses 'comunication_way', so we map it here.
      communicationWay: json['comunication_way'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'identifier': identifier,
      'comunication_way': communicationWay,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<Supplier> fromJsonList(String source) {
    final decoded = json.decode(source) as List<dynamic>;
    return decoded.map((e) => Supplier.fromJson(e)).toList();
  }
}
