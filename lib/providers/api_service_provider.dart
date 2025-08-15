import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';

/// مزود موحد لخدمة API يمكن استخدامه في جميع الشاشات
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
