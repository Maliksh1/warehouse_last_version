// lib/providers/api_service_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
