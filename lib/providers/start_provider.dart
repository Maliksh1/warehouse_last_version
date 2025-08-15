import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final startApplicationProvider = FutureProvider<StartAppState>((ref) async {
  final storage = FlutterSecureStorage();

  final isAdminCreatedStr = await storage.read(key: 'is_admin_created');
  final isLoggedInStr = await storage.read(key: 'is_logged_in');

  final isAdminCreated = isAdminCreatedStr == 'true';
  final isLoggedIn = isLoggedInStr == 'true';

  return StartAppState(
    isAdminCreated: isAdminCreated,
    isLoggedIn: isLoggedIn,
  );
});

class StartAppState {
  final bool isAdminCreated;
  final bool isLoggedIn;

  StartAppState({required this.isAdminCreated, required this.isLoggedIn});
}
