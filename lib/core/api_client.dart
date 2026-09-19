import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';
import 'demo_backend.dart';

/// نقطة اتصال واحدة مع Laravel Backend (sikka-backend).
/// غيّر baseUrl هنا لعنوان السيرفر بتاعك:
/// - 10.0.2.2 لو شغال على محاكي أندرويد ومشغل php artisan serve على نفس الجهاز
/// - IP الشبكة المحلية بتاع جهازك لو بتجرب على موبايل حقيقي على نفس الواي فاي
class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Public wrapper so screens (e.g. splash) can check if a rider is
  /// already logged in without reaching into SharedPreferences directly.
  static Future<String?> getSavedToken() => _token();

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _token();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String path, {bool auth = true}) async {
    if (AppConfig.demoMode) return DemoBackend.handle('GET', path, null);
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers(auth: auth));
    return _handle(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = false}) async {
    if (AppConfig.demoMode) return DemoBackend.handle('POST', path, body);
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  static Future<dynamic> delete(String path, {bool auth = true}) async {
    if (AppConfig.demoMode) return DemoBackend.handle('DELETE', path, null);
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers(auth: auth));
    return _handle(res);
  }

  static dynamic _handle(http.Response res) {
    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }
    final message = decoded is Map && decoded['message'] != null
        ? decoded['message']
        : 'حدث خطأ (${res.statusCode})';
    throw ApiException(message.toString());
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
