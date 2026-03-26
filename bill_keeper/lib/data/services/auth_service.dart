import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthResult {
  success,
  invalidPhone,
  invalidCode,
  codeExpired,
  tooManyAttempts,
  tooManyWrongAttempts,
  networkError,
}

class AuthResultData {
  final AuthResult result;
  final String? message;

  AuthResultData(this.result, [this.message]);
}

class AuthService {
  static const String _phoneKey = 'user_phone';
  static const String _loginTimeKey = 'login_time';
  static const String _smsCodeKey = 'sms_code';
  static const String _smsCodeTimeKey = 'sms_code_time';
  static const String _smsAttemptsKey = 'sms_attempts';
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _smsCodeDateKey = 'sms_code_date';
  static const String _wrongCodeAttemptsKey = 'wrong_code_attempts';

  static const int _codeValidMinutes = 5;
  static const int _maxSmsPerDay = 10;
  static const int _maxWrongCodeAttempts = 5;
  static const int _maxLoginAttemptsPerDay = 20;

  final Random _random = Random();

  String _generateCode() {
    return List.generate(6, (_) => _random.nextInt(10)).join();
  }

  Future<AuthResultData> requestSMSCode(String phone) async {
    if (!_isValidPhone(phone)) {
      return AuthResultData(AuthResult.invalidPhone, '手机号格式不正确');
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastSmsDate = prefs.getString(_smsCodeDateKey) ?? '';
    int smsAttempts = 0;

    if (lastSmsDate == today) {
      smsAttempts = prefs.getInt(_smsAttemptsKey) ?? 0;
    }

    if (smsAttempts >= _maxSmsPerDay) {
      return AuthResultData(AuthResult.tooManyAttempts, '今日发送次数已用完');
    }

    final code = _generateCode();
    await prefs.setString(_smsCodeKey, code);
    await prefs.setInt(_smsCodeTimeKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(_smsCodeDateKey, today);
    await prefs.setInt(_smsAttemptsKey, smsAttempts + 1);
    await prefs.setString('sms_code_phone', phone);
    await prefs.setInt(_wrongCodeAttemptsKey, 0);

    return AuthResultData(AuthResult.success);
  }

  Future<AuthResultData> verifyCode(String phone, String code) async {
    if (!_isValidPhone(phone)) {
      return AuthResultData(AuthResult.invalidPhone, '手机号格式不正确');
    }

    if (code.length != 6) {
      return AuthResultData(AuthResult.invalidCode, '验证码应为6位数字');
    }

    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_smsCodeKey);
    final savedTime = prefs.getInt(_smsCodeTimeKey) ?? 0;
    final savedPhone = prefs.getString('sms_code_phone');

    if (savedPhone != phone) {
      return AuthResultData(AuthResult.invalidCode, '验证码与手机号不匹配');
    }

    if (savedCode == null || savedCode.isEmpty) {
      return AuthResultData(AuthResult.codeExpired, '请先获取验证码');
    }

    final codeTime = DateTime.fromMillisecondsSinceEpoch(savedTime);
    final now = DateTime.now();
    final diffMinutes = now.difference(codeTime).inMinutes;

    if (diffMinutes > _codeValidMinutes) {
      return AuthResultData(AuthResult.codeExpired, '验证码已过期，请重新获取');
    }

    if (savedCode != code) {
      int wrongAttempts = prefs.getInt(_wrongCodeAttemptsKey) ?? 0;
      wrongAttempts++;
      await prefs.setInt(_wrongCodeAttemptsKey, wrongAttempts);
      
      if (wrongAttempts >= _maxWrongCodeAttempts) {
        await prefs.remove(_smsCodeKey);
        await prefs.remove(_smsCodeTimeKey);
        await prefs.setInt(_wrongCodeAttemptsKey, 0);
        return AuthResultData(AuthResult.tooManyWrongAttempts, '验证码错误次数过多，请重新获取');
      }
      
      return AuthResultData(AuthResult.invalidCode, '验证码错误，剩余${_maxWrongCodeAttempts - wrongAttempts}次');
    }

    await prefs.setString(_phoneKey, phone);
    await prefs.setInt(_loginTimeKey, now.millisecondsSinceEpoch);
    await prefs.remove(_smsCodeKey);
    await prefs.remove(_smsCodeTimeKey);
    await prefs.remove(_wrongCodeAttemptsKey);

    return AuthResultData(AuthResult.success);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_phoneKey);
    return phone != null && phone.isNotEmpty;
  }

  Future<String?> getCurrentPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
    await prefs.remove(_loginTimeKey);
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^1[3-9]\d{9}$');
    return regex.hasMatch(phone);
  }
}
