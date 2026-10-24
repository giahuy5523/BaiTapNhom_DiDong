import 'dart:convert';

import '../config/api_config.dart';
import '../models/phone.dart';
import 'phone_service.dart';

/// Dữ liệu mẫu cùng cấu trúc với API thật (xem docs/samples/phones.json).
class MockPhoneService implements PhoneSource {
  static const String _json = '''
[
  {"id":1,"name":"iPhone 15 pro Max","price":18000000,"imageUrl":"https://placehold.co/400x400/png?text=iPhone+15+Pro+Max","description":"iPhone 15 Pro Max là mẫu điện thoại cao cấp ra mắt năm 2023, khung titan, chip A17 Pro, camera zoom quang học 5x. Sản phẩm chính hãng, bảo hành đầy đủ."},
  {"id":2,"name":"iPhone 15","price":14000000,"imageUrl":"https://placehold.co/400x400/png?text=iPhone+15","description":"Hàng chính hãng"},
  {"id":3,"name":"Oppo Reno 10 Pro+","price":13000000,"imageUrl":"https://placehold.co/400x400/png?text=Reno+10+Pro%2B","description":"Hàng chính hãng"},
  {"id":4,"name":"Oppo Reno 11F","price":10000000,"imageUrl":"https://placehold.co/400x400/png?text=Reno+11F","description":"Hàng chính hãng"},
  {"id":5,"name":"Galaxy 24 Plus","price":16500000,"imageUrl":"https://placehold.co/400x400/png?text=Galaxy+24+Plus","description":"Hàng chính hãng"},
  {"id":6,"name":"Xiaomi 14","price":12000000,"imageUrl":"https://placehold.co/400x400/png?text=Xiaomi+14","description":"Hàng chính hãng"},
  {"id":7,"name":"Xiaomi-Redmi A3","price":2990000,"imageUrl":"https://placehold.co/400x400/png?text=Redmi+A3","description":"Hàng chính hãng"}
]
''';

  List<Phone> get _all => (jsonDecode(_json) as List)
      .map((e) => Phone.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<List<Phone>> getPhones() async {
    await _delay();
    switch (ApiConfig.mockScenario) {
      case 'error':
        throw const ApiException('NO_CONNECTION', 'Không kết nối được máy chủ');
      case 'empty':
        return [];
      default:
        return _all;
    }
  }

  @override
  Future<Phone> getPhone(int id) async {
    await _delay();
    if (ApiConfig.mockScenario == 'error') {
      throw const ApiException('INTERNAL_ERROR', 'Máy chủ gặp lỗi', 500);
    }
    if (id <= 0) {
      throw const ApiException('INVALID_ID', 'Mã điện thoại không hợp lệ', 400);
    }
    return _all.firstWhere(
      (p) => p.id == id,
      orElse: () => throw const ApiException(
          'PHONE_NOT_FOUND', 'Không tìm thấy điện thoại', 404),
    );
  }
}
