import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    test('手机号格式验证 - 正确格式', () {
      expect(_isValidPhone('13812345678'), isTrue);
      expect(_isValidPhone('19912345678'), isTrue);
      expect(_isValidPhone('14712345678'), isTrue);
    });

    test('手机号格式验证 - 错误格式', () {
      expect(_isValidPhone('12345678901'), isFalse);
      expect(_isValidPhone('1381234567'), isFalse);
      expect(_isValidPhone('abc12345678'), isFalse);
      expect(_isValidPhone('138123456789'), isFalse);
    });
  });
}

bool _isValidPhone(String phone) {
  final regex = RegExp(r'^1[3-9]\d{9}$');
  return regex.hasMatch(phone);
}
