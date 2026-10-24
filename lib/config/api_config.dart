/// Cấu hình tập trung. Đổi giá trị bằng --dart-define, không sửa mã.
///   flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://10.0.2.2:5000
class ApiConfig {
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:5000');

  /// true = dùng dữ liệu mẫu (trước M3). Sang M3 chạy với USE_MOCK=false.
  static const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  /// Chỉ dùng cho mock: ok | empty | error  (để thử T07, T08, T09)
  static const String mockScenario =
      String.fromEnvironment('MOCK_SCENARIO', defaultValue: 'ok');

  static const Duration timeout = Duration(seconds: 10);
}
