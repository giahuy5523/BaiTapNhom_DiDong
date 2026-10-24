import 'dart:convert';

import 'package:flutter/services.dart';

import '../config/api_config.dart';
import '../models/phone.dart';
import 'phone_service.dart';

/// Dữ liệu mẫu cùng cấu trúc với API thật (xem docs/samples/phones.json).
class MockPhoneService implements PhoneSource {
  // Dùng chung JSON bàn giao đã đóng gói trong ứng dụng, tránh lệch giá/mô tả với SQL.
  Future<List<Phone>> _loadPhones() async {
    final text = await rootBundle.loadString('docs/samples/phones.json');
    return (jsonDecode(text) as List).map((entry) {
      final data = Map<String, dynamic>.from(entry as Map);
      // Giữ đường dẫn ảnh nhưng dùng host cấu hình cho thiết bị đang chạy.
      data['imageUrl'] = Uri.parse(ApiConfig.baseUrl)
          .resolve(Uri.parse(data['imageUrl'] as String).path)
          .toString();
      return Phone.fromJson(data);
    }).toList();
  }

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
        return _loadPhones();
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
    final phones = await _loadPhones();
    return phones.firstWhere(
      (p) => p.id == id,
      orElse: () => throw const ApiException(
        'PHONE_NOT_FOUND',
        'Không tìm thấy điện thoại',
        404,
      ),
    );
  }
}
