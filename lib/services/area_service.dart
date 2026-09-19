import '../core/api_client.dart';
import '../models/area.dart';

class AreaService {
  static Future<List<Area>> list() async {
    final res = await ApiClient.get('/areas', auth: false);
    final List areas = res['areas'];
    return areas.map((a) => Area.fromJson(a)).toList();
  }
}
