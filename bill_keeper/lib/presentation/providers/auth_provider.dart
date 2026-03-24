import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  AuthNotifier() : super(const AsyncValue.data(false)) {
    _checkLoginStatus();
  }

  static const _phoneKey = 'user_phone';
  static const _loginTimeKey = 'login_time';

  Future<void> _checkLoginStatus() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString(_phoneKey);
      if (phone != null && phone.isNotEmpty) {
        state = const AsyncValue.data(true);
      } else {
        state = const AsyncValue.data(false);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendCode(String phone) async {
    // Simulate sending SMS code
    await Future.delayed(const Duration(seconds: 1));
    // In production, this would call an SMS API
  }

  Future<bool> verifyCode(String phone, String code) async {
    state = const AsyncValue.loading();
    try {
      // Simulate verification
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo, accept any 6-digit code
      if (code.length == 6) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_phoneKey, phone);
        await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
        state = const AsyncValue.data(true);
        return true;
      }
      state = const AsyncValue.data(false);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
    await prefs.remove(_loginTimeKey);
    state = const AsyncValue.data(false);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier();
});

final authStateProvider = StreamProvider<bool>((ref) async* {
  final authNotifier = ref.watch(authNotifierProvider);
  yield authNotifier.valueOrNull ?? false;
});
