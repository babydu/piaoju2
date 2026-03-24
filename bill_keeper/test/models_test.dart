import 'package:flutter_test/flutter_test.dart';
import 'package:bill_keeper/domain/models/user.dart';
import 'package:bill_keeper/domain/models/bill.dart';
import 'package:bill_keeper/domain/models/bill_image.dart';
import 'package:bill_keeper/domain/models/collection.dart';
import 'package:bill_keeper/domain/models/tag.dart';

void main() {
  group('User Model', () {
    test('创建用户成功', () {
      final user = User(
        phone: '13812345678',
        storageUsed: 1024,
        storageTotal: User.defaultStorageTotal,
        createdAt: DateTime(2024, 1, 1),
      );
      
      expect(user.phone, equals('13812345678'));
      expect(user.storageUsed, equals(1024));
      expect(user.storageTotal, equals(1073741824));
    });

    test('copyWith 正确', () {
      final user = User(
        phone: '13812345678',
        storageUsed: 1024,
        storageTotal: User.defaultStorageTotal,
        createdAt: DateTime(2024, 1, 1),
      );
      
      final updated = user.copyWith(nickname: '测试用户');
      
      expect(updated.phone, equals('13812345678'));
      expect(updated.nickname, equals('测试用户'));
    });
  });

  group('Bill Model', () {
    test('创建票据成功', () {
      final bill = Bill(
        id: 'bill1',
        title: '测试票据',
        ocrContent: 'OCR 内容',
        location: '北京',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      
      expect(bill.id, equals('bill1'));
      expect(bill.title, equals('测试票据'));
      expect(bill.images, isEmpty);
      expect(bill.tags, isEmpty);
    });

    test('copyWith 正确', () {
      final bill = Bill(
        id: 'bill1',
        title: '测试票据',
        ocrContent: 'OCR 内容',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      
      final updated = bill.copyWith(title: '新标题');
      
      expect(updated.title, equals('新标题'));
      expect(updated.id, equals('bill1'));
    });
  });

  group('BillImage Model', () {
    test('创建图片成功', () {
      final image = BillImage(
        id: 'img1',
        billId: 'bill1',
        localPath: '/path/to/image.jpg',
        thumbnailPath: '/path/to/thumb.jpg',
        sortOrder: 0,
      );
      
      expect(image.id, equals('img1'));
      expect(image.billId, equals('bill1'));
      expect(image.sortOrder, equals(0));
    });
  });

  group('Collection Model', () {
    test('创建合集成功', () {
      final collection = Collection(
        id: 'col1',
        name: '我的合集',
        userPhone: '13812345678',
        createdAt: DateTime(2024, 1, 1),
        billCount: 5,
      );
      
      expect(collection.id, equals('col1'));
      expect(collection.name, equals('我的合集'));
      expect(collection.billCount, equals(5));
    });
  });

  group('Tag Model', () {
    test('创建标签成功', () {
      final tag = Tag(
        id: 'tag1',
        name: '发票',
        userPhone: '13812345678',
        createdAt: DateTime(2024, 1, 1),
        billCount: 10,
      );
      
      expect(tag.id, equals('tag1'));
      expect(tag.name, equals('发票'));
      expect(tag.billCount, equals(10));
    });
  });
}
