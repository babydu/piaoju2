import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final authStateProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.valueOrNull == AuthState.authenticated;
});

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(AuthState.initial)) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    state = const AsyncValue.loading();
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      state = AsyncValue.data(isLoggedIn ? AuthState.authenticated : AuthState.unauthenticated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AuthResultData> sendCode(String phone) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.requestSMSCode(phone);
      if (result.result == AuthResult.success) {
        state = const AsyncValue.data(AuthState.unauthenticated);
      } else {
        state = AsyncValue.error(Exception(result.message), StackTrace.current);
      }
      return result;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return AuthResultData(AuthResult.networkError, e.toString());
    }
  }

  Future<bool> verifyCode(String phone, String code) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.verifyCode(phone, code);
      if (result.result == AuthResult.success) {
        state = const AsyncValue.data(AuthState.authenticated);
        return true;
      } else {
        state = const AsyncValue.data(AuthState.unauthenticated);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(AuthState.unauthenticated);
  }

  Future<String?> getCurrentPhone() async {
    return _authService.getCurrentPhone();
  }
}
