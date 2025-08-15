import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/services/auth_service.dart';
import 'package:warehouse/core/exceptions.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AsyncValue.data(false));

  Future<void> login({
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await ref.read(authServiceProvider).login(
            email: email,
            password: password,
            phoneNumber: phoneNumber,
          );

      await ref.read(authServiceProvider).saveSession(response);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      print('❌ فشل تسجيل الدخول: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> registerAdminExtended({
    required String email,
    required String password,
    required String phoneNumber,
    required String salary,
    required String birthDay,
    required String country,
    required String startTime,
    required String workHours,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).registerAdminExtended(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            salary: salary,
            birthDay: birthDay,
            country: country,
            startTime: startTime,
            workHours: workHours,
          );
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
