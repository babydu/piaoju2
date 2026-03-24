import 'package:flutter_test/flutter_test.dart';
import 'package:bill_keeper/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('应用名称正确', () {
      expect(AppConstants.appName, equals('票夹管家'));
    });

    test('存储限制正确', () {
      expect(AppConstants.maxStorageTotal, equals(1024 * 1024 * 1024));
      expect(AppConstants.maxImageCount, equals(9));
      expect(AppConstants.maxImageSize, equals(20 * 1024 * 1024));
      expect(AppConstants.maxBillCount, equals(10000));
      expect(AppConstants.maxCollectionCount, equals(100));
    });

    test('输入长度限制正确', () {
      expect(AppConstants.maxTitleLength, equals(100));
      expect(AppConstants.maxRemarkLength, equals(500));
      expect(AppConstants.maxTagNameLength, equals(20));
      expect(AppConstants.maxCollectionNameLength, equals(30));
    });

    test('登录安全限制正确', () {
      expect(AppConstants.smsCodeValidMinutes, equals(5));
      expect(AppConstants.maxSmsPerDay, equals(10));
      expect(AppConstants.maxWrongCodeAttempts, equals(5));
      expect(AppConstants.maxLoginAttemptsPerDay, equals(20));
    });

    test('回收站限制正确', () {
      expect(AppConstants.recycleBinRetentionDays, equals(30));
      expect(AppConstants.recycleBinReminderDays, equals(7));
    });

    test('分页大小正确', () {
      expect(AppConstants.pageSize, equals(20));
      expect(AppConstants.searchHistoryMaxCount, equals(10));
    });
  });
}
