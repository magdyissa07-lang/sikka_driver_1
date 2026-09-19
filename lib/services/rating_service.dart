import '../core/api_client.dart';

class RatingService {
  static Future<void> rate({required int tripId, required int stars, String? comment}) async {
    await ApiClient.post('/rider/ratings', {
      'trip_id': tripId,
      'stars': stars,
      'comment': comment,
    }, auth: true);
  }
}
