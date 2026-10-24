import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/phone.dart';
import 'package:flutter_application_1/screens/phone_list_screen.dart';
import 'package:flutter_application_1/services/phone_service.dart';

// Dữ liệu cố định để kiểm tra điều hướng mà không cần khởi động SQL Server/API.
class TestPhoneSource implements PhoneSource {
  int? requestedId;

  static const phone = Phone(
    id: 7,
    name: 'Điện thoại kiểm thử',
    price: 2500000,
    imageUrl: 'http://example.test/phone.jpg',
    description: 'Mô tả đầy đủ của điện thoại kiểm thử.',
  );

  @override
  Future<List<Phone>> getPhones() async => [phone];

  @override
  Future<Phone> getPhone(int id) async {
    requestedId = id;
    return phone;
  }
}

void main() {
  testWidgets('Chọn điện thoại, xem đúng chi tiết rồi quay lại danh sách', (
    WidgetTester tester,
  ) async {
    final source = TestPhoneSource();
    await tester.pumpWidget(MaterialApp(home: PhoneListScreen(source: source)));
    await tester.pumpAndSettle();

    expect(find.text('DANH MỤC SẢN PHẨM'), findsOneWidget);
    expect(find.text(TestPhoneSource.phone.name), findsOneWidget);

    await tester.tap(find.text(TestPhoneSource.phone.name));
    await tester.pumpAndSettle();

    expect(source.requestedId, TestPhoneSource.phone.id);
    expect(find.text('THÔNG TIN SẢN PHẨM'), findsOneWidget);
    expect(find.text('Tên: ${TestPhoneSource.phone.name}'), findsOneWidget);
    expect(find.text(TestPhoneSource.phone.description), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('DANH MỤC SẢN PHẨM'), findsOneWidget);
    expect(find.text(TestPhoneSource.phone.name), findsOneWidget);
  });
}
