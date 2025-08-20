import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/services/distribution_center_api.dart';

final distributionCentersProvider =
    FutureProvider.family.autoDispose<List<DistributionCenter>, int>(
  (ref, warehouseId) async {
    return DistributionCenterApi.fetchByWarehouse(warehouseId);
  },
);
