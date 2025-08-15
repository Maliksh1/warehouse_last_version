import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final specializationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getSpecializations();
});
