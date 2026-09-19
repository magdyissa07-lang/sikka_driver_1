import '../core/api_client.dart';
import '../models/trip.dart';

class TripService {
  static Future<Map<String, dynamic>> estimate({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    return await ApiClient.post('/rider/trips/estimate', {
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
    }, auth: true);
  }

  static Future<Trip> requestTrip({
    required double pickupLat,
    required double pickupLng,
    String? pickupText,
    required double dropoffLat,
    required double dropoffLng,
    String? dropoffText,
    required String category,
    required String paymentMethod,
  }) async {
    final res = await ApiClient.post('/rider/trips', {
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_text': pickupText,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
      'dropoff_text': dropoffText,
      'category': category,
      'payment_method': paymentMethod,
    }, auth: true);
    return Trip.fromJson(res['trip']);
  }

  static Future<Trip> show(int tripId) async {
    final res = await ApiClient.get('/rider/trips/$tripId', auth: true);
    return Trip.fromJson(res['trip']);
  }

  static Future<void> cancel(int tripId) async {
    await ApiClient.post('/rider/trips/$tripId/cancel', {}, auth: true);
  }
}
