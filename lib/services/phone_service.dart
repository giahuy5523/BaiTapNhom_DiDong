import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/phone.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;
  const ApiException(this.code, this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Giao diện chung để màn hình không biết đang dùng mock hay API thật.
abstract class PhoneSource {
  Future<List<Phone>> getPhones();
  Future<Phone> getPhone(int id);
}

class PhoneService implements PhoneSource {
  PhoneService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  @override
  Future<List<Phone>> getPhones() async {
    final body = await _get('/api/phones');
    return (body as List)
        .map((e) => Phone.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Phone> getPhone(int id) async {
    final body = await _get('/api/phones/$id');
    return Phone.fromJson(body as Map<String, dynamic>);
  }

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(ApiConfig.timeout);
      final text = utf8.decode(res.bodyBytes); // giữ đúng tiếng Việt
      if (res.statusCode == 200) return jsonDecode(text);
      throw _errorFrom(res.statusCode, text);
    } on TimeoutException {
      throw const ApiException('TIMEOUT', 'Máy chủ phản hồi quá lâu');
    } on SocketException {
      throw const ApiException('NO_CONNECTION', 'Không kết nối được máy chủ');
    } on http.ClientException {
      throw const ApiException('NO_CONNECTION', 'Không kết nối được máy chủ');
    } on FormatException {
      throw const ApiException('BAD_RESPONSE', 'Dữ liệu trả về không hợp lệ');
    } on TypeError {
      throw const ApiException('BAD_RESPONSE', 'Dữ liệu trả về sai cấu trúc');
    }
  }

  ApiException _errorFrom(int status, String body) {
    try {
      final m = jsonDecode(body) as Map<String, dynamic>;
      return ApiException(
          m['code'] as String, m['message'] as String, status);
    } catch (_) {
      return ApiException(
          'HTTP_$status', 'Máy chủ gặp lỗi ($status)', status);
    }
  }
}
