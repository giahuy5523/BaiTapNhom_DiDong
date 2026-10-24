import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/phone.dart';
import 'package:flutter_application_1/screens/phone_list_screen.dart';
import 'package:flutter_application_1/services/phone_service.dart';
import 'package:flutter_application_1/utils/format_vnd.dart';

const item = Phone(
  id: 2,
  name: 'Điện thoại số hai',
  price: 14000000,
  imageUrl: 'http://example.test/image.jpg',
  description: 'Mô tả tiếng Việt đầy đủ',
);

class Source implements PhoneSource {
  int listCalls = 0, detailCalls = 0;
  int? selectedId;
  List<Phone> phones = [item];
  bool listError = false, detailError = false;
  Completer<List<Phone>>? pending;
  @override
  Future<List<Phone>> getPhones() async {
    listCalls++;
    if (pending != null) return pending!.future;
    if (listError) {
      throw const ApiException('NO_CONNECTION', 'Không kết nối được máy chủ');
    }
    return phones;
  }

  @override
  Future<Phone> getPhone(int id) async {
    detailCalls++;
    selectedId = id;
    if (detailError) {
      throw const ApiException(
        'PHONE_NOT_FOUND',
        'Không tìm thấy điện thoại.',
        404,
      );
    }
    return item;
  }
}

Future<void> show(WidgetTester t, Source s) async {
  await t.pumpWidget(MaterialApp(home: PhoneListScreen(source: s)));
  await t.pumpAndSettle();
}

void main() {
  test('Định dạng VND', () {
    expect(formatVnd(0), '0 đ');
    expect(formatVnd(1000), '1.000 đ');
    expect(formatVnd(14000000), '14.000.000 đ');
  });
  testWidgets('Hiện danh sách sau khi tải', (t) async {
    final s = Source()..pending = Completer<List<Phone>>();
    await t.pumpWidget(MaterialApp(home: PhoneListScreen(source: s)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    s.pending!.complete([item]);
    await t.pumpAndSettle();
    expect(find.text(item.name), findsOneWidget);
  });
  testWidgets('Danh sách rỗng rồi tải lại', (t) async {
    final s = Source()..phones = [];
    await show(t, s);
    expect(find.text('Chưa có điện thoại nào'), findsOneWidget);
    s.phones = [item];
    await t.tap(find.text('Tải lại'));
    await t.pumpAndSettle();
    expect(find.text(item.name), findsOneWidget);
    expect(s.listCalls, 2);
  });
  testWidgets('Mất kết nối rồi thử lại', (t) async {
    final s = Source()..listError = true;
    await show(t, s);
    expect(find.text('Không kết nối được máy chủ'), findsOneWidget);
    s.listError = false;
    await t.tap(find.text('Thử lại'));
    await t.pumpAndSettle();
    expect(find.text(item.name), findsOneWidget);
    expect(s.listCalls, 2);
  });
  testWidgets('Chi tiết 404 rồi quay lại', (t) async {
    final s = Source()..detailError = true;
    await show(t, s);
    await t.tap(find.text(item.name));
    await t.pumpAndSettle();
    expect(s.selectedId, 2);
    expect(find.text('Không tìm thấy điện thoại.'), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    expect(find.text('DANH MỤC SẢN PHẨM'), findsOneWidget);
  });
  testWidgets('Thử lại chi tiết và hiển thị giá', (t) async {
    final s = Source()..detailError = true;
    await show(t, s);
    await t.tap(find.text(item.name));
    await t.pumpAndSettle();
    s.detailError = false;
    await t.tap(find.text('Thử lại'));
    await t.pumpAndSettle();
    expect(find.text('Tên: ${item.name}'), findsOneWidget);
    expect(s.detailCalls, 2);
    expect(find.text('Giá: 14.000.000 đ'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('Ảnh lỗi có ảnh thay thế', (t) async {
    await show(t, Source());
    expect(find.byIcon(Icons.phone_android), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('Màn nhỏ với chữ lớn', (t) async {
    t.view.physicalSize = const Size(320, 568);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: PhoneListScreen(source: Source()),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await t.tap(find.text(item.name));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
}
