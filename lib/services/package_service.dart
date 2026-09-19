import '../core/api_client.dart';

class PackageService {
  static Future<List<dynamic>> list() async {
    final res = await ApiClient.get('/rider/packages', auth: true);
    return res['packages'];
  }

  static Future<Map<String, dynamic>> purchase(int packageId) async {
    return await ApiClient.post('/rider/packages/$packageId/purchase', {}, auth: true);
  }

  static Future<List<dynamic>> myPackages() async {
    final res = await ApiClient.get('/rider/my-packages', auth: true);
    return res['rider_packages'];
  }
}
