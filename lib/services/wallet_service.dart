import '../core/api_client.dart';

class WalletService {
  static Future<Map<String, dynamic>> load() async {
    final res = await ApiClient.get('/rider/wallet', auth: true);
    return {
      'balance': double.tryParse(res['wallet']['balance'].toString()) ?? 0.0,
      'transactions': res['transactions'] as List<dynamic>,
    };
  }

  static Future<double> topup(double amount) async {
    final res = await ApiClient.post('/rider/wallet/topup', {'amount': amount}, auth: true);
    return double.tryParse(res['wallet']['balance'].toString()) ?? 0.0;
  }
}
