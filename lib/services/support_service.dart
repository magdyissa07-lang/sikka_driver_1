import '../core/api_client.dart';

class SupportService {
  static Future<List<dynamic>> list() async {
    final res = await ApiClient.get('/rider/support-tickets', auth: true);
    return res['support_tickets'];
  }

  static Future<void> create({required String category, required String description}) async {
    await ApiClient.post('/rider/support-tickets', {
      'category': category,
      'description': description,
    }, auth: true);
  }
}
