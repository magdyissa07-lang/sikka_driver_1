import '../core/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    required String residenceType,
    required int areaId,
    required String residenceFreeText,
    required double pickupLat,
    required double pickupLng,
    String language = 'ar',
  }) async {
    final res = await ApiClient.post('/rider/register', {
      'full_name': fullName,
      'phone': phone,
      'residence_type': residenceType,
      'area_id': areaId,
      'residence_free_text': residenceFreeText,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'language': language,
    });
    return res;
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final res = await ApiClient.post('/rider/verify-otp', {
      'phone': phone,
      'code': code,
    });
    if (res['token'] != null) {
      await ApiClient.saveToken(res['token']);
    }
    return res;
  }

  static Future<void> resendOtp(String phone) async {
    await ApiClient.post('/rider/resend-otp', {'phone': phone});
  }

  static Future<void> logout() async {
    await ApiClient.clearToken();
  }
}
