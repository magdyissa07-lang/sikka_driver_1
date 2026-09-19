import '../core/api_client.dart';

class SavedPlacesService {
  static Future<List<dynamic>> list() async {
    final res = await ApiClient.get('/rider/saved-places', auth: true);
    return res['saved_places'];
  }

  static Future<void> add({required String label, required String addressText}) async {
    await ApiClient.post('/rider/saved-places', {
      'label': label,
      'address_text': addressText,
    }, auth: true);
  }

  static Future<void> remove(int id) async {
    await ApiClient.delete('/rider/saved-places/$id', auth: true);
  }
}
