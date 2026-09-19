import '../core/api_client.dart';

class CarpoolService {
  static Future<List<dynamic>> list() async {
    final res = await ApiClient.get('/rider/carpool-schedules', auth: true);
    return res['carpool_schedules'];
  }

  static Future<void> create({
    required String childName,
    required String schoolName,
    required String pickupTime,
    required String returnTime,
    required List<String> daysOfWeek,
  }) async {
    await ApiClient.post('/rider/carpool-schedules', {
      'child_name': childName,
      'school_name': schoolName,
      'pickup_time': pickupTime,
      'return_time': returnTime,
      'days_of_week': daysOfWeek,
    }, auth: true);
  }

  static Future<void> setPaused(int id, bool paused) async {
    await ApiClient.post('/rider/carpool-schedules/$id/${paused ? 'pause' : 'resume'}', {}, auth: true);
  }
}
