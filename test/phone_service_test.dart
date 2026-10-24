import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_1/services/phone_service.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/services/mock_phone_service.dart';

final phoneJson = <String, dynamic>{
  'id': 1,
  'name': 'Điện thoại tiếng Việt',
  'price': 18000000,
  'imageUrl': 'http://localhost:5000/images/phone.jpg',
  'description': 'Mô tả đầy đủ',
};
Matcher apiError(String code, [int? status]) => isA<ApiException>()
    .having((e) => e.code, 'code', code)
    .having((e) => e.statusCode, 'status', status);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final base in [
    'http://localhost:5000',
    'http://localhost:5000/',
    ' http://localhost:5000/// ',
  ]) {
    test('Chuẩn hóa URL $base', () async {
      final paths = <String>[];
      final client = MockClient((r) async {
        paths.add(r.url.path);
        return http.Response(
          jsonEncode(r.url.path.endsWith('/1') ? phoneJson : [phoneJson]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      addTearDown(client.close);
      final source = PhoneService(client: client, baseUrl: base);
      final phones = await source.getPhones();
      final detail = await source.getPhone(1);
      expect(paths, ['/api/phones', '/api/phones/1']);
      expect(phones.single.name, 'Điện thoại tiếng Việt');
      expect(detail.price, 18000000);
    });
  }
  for (final entry in {
    'Không phải JSON': 'not json',
    'Sai root danh sách': '{}',
    'Thiếu trường': '[{"id":1}]',
  }.entries) {
    test('BAD_RESPONSE khi ${entry.key}', () async {
      final c = MockClient((r) async => http.Response(entry.value, 200));
      addTearDown(c.close);
      await expectLater(
        PhoneService(client: c).getPhones(),
        throwsA(apiError('BAD_RESPONSE')),
      );
    });
  }
  test('BAD_RESPONSE khi chi tiết là mảng', () async {
    final c = MockClient((r) async => http.Response('[]', 200));
    addTearDown(c.close);
    await expectLater(
      PhoneService(client: c).getPhone(1),
      throwsA(apiError('BAD_RESPONSE')),
    );
  });
  for (final entry in {
    400: 'INVALID_ID',
    404: 'PHONE_NOT_FOUND',
    500: 'INTERNAL_ERROR',
  }.entries) {
    test('Giữ mã lỗi HTTP ${entry.key}', () async {
      final c = MockClient(
        (r) async => http.Response(
          jsonEncode({'code': entry.value, 'message': 'Thông báo tiếng Việt'}),
          entry.key,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
      addTearDown(c.close);
      await expectLater(
        PhoneService(client: c).getPhone(1),
        throwsA(apiError(entry.value, entry.key)),
      );
    });
  }
  test('Lỗi HTTP không phải JSON vẫn giữ trạng thái', () async {
    final c = MockClient((r) async => http.Response('Bad gateway', 502));
    addTearDown(c.close);
    await expectLater(
      PhoneService(client: c).getPhones(),
      throwsA(apiError('HTTP_502', 502)),
    );
  });
  test('Hết thời gian chờ', () async {
    final c = MockClient((r) async => throw TimeoutException('test'));
    addTearDown(c.close);
    await expectLater(
      PhoneService(client: c).getPhones(),
      throwsA(apiError('TIMEOUT')),
    );
  });
  test('Mất kết nối', () async {
    final c = MockClient((r) async => throw const SocketException('test'));
    addTearDown(c.close);
    await expectLater(
      PhoneService(client: c).getPhones(),
      throwsA(apiError('NO_CONNECTION')),
    );
  });
  test('Mock khớp toàn bộ JSON bàn giao và giá Redmi A3', () async {
    final fixture = jsonDecode(
      await rootBundle.loadString('docs/samples/phones.json'),
    ) as List;
    final mock = MockPhoneService();
    final phones = await mock.getPhones();
    expect(phones.length, fixture.length);
    for (var i = 0; i < phones.length; i++) {
      final p = phones[i];
      final f = fixture[i] as Map<String, dynamic>;
      expect(
        [p.id, p.name, p.price, p.imageUrl, p.description],
        [
          f['id'],
          f['name'],
          f['price'],
          Uri.parse(ApiConfig.baseUrl)
              .resolve(Uri.parse(f['imageUrl'] as String).path)
              .toString(),
          f['description'],
        ],
      );
    }
    expect(phones.singleWhere((p) => p.id == 7).price, 2500000);
    final detail = await mock.getPhone(1);
    expect(detail.description, phones.first.description);
  });
}
