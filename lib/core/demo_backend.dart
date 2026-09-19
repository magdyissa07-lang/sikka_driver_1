/// باك إند وهمي بالكامل، شغال داخل التطبيق نفسه، عشان تقدر تجرب كل
/// شاشات ورحلة الاستخدام على موبايلك من غير أي سيرفر حقيقي أو إنترنت.
///
/// المسارات والأشكال (JSON shapes) هنا مطابقة تمامًا لعقد الـAPI الحقيقي
/// في sikka-backend (routes/api.php)، فلما تجهز السيرفر وتقفل demoMode،
/// مفيش أي كود في الشاشات أو الـServices هيحتاج تغيير.
library;

class DemoBackend {
  DemoBackend._();

  static int _idSeq = 1000;
  static int _nextId() => _idSeq++;

  // ---- حالة وهمية محفوظة في الذاكرة طول ما التطبيق شغال ----
  static final Map<int, Map<String, dynamic>> _trips = {};
  static final Map<int, DateTime> _tripCreatedAt = {};
  static final List<Map<String, dynamic>> _ridersPackages = [];
  static final List<Map<String, dynamic>> _savedPlaces = [
    {'id': 1, 'label': 'المنزل', 'address_text': 'بيفرلي هيلز، فيلا 12', 'lat': 29.99, 'lng': 30.93},
    {'id': 2, 'label': 'المدرسة', 'address_text': 'مدرسة النيل الدولية', 'lat': 30.02, 'lng': 31.00},
  ];
  static final List<Map<String, dynamic>> _carpoolSchedules = [];
  static final List<Map<String, dynamic>> _walletTx = [
    {'id': 1, 'type': 'credit', 'amount': 150.0, 'reason': 'topup', 'created_at': '2026-09-10'},
    {'id': 2, 'type': 'debit', 'amount': 42.0, 'reason': 'trip_payment', 'created_at': '2026-09-12'},
  ];
  static double _walletBalance = 108.0;
  static final List<Map<String, dynamic>> _supportTickets = [];

  static String? _lastOtpPhone;

  /// نقطة الدخول الوحيدة - بتحاكي رحلة الـHTTP request/response بالكامل
  /// (فيها تأخير بسيط زي السيرفر الحقيقي).
  static Future<Map<String, dynamic>> handle(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    // GET /areas
    if (method == 'GET' && path == '/areas') {
      return {
        'areas': [
          {'id': 1, 'name_ar': 'بيفرلي هيلز، الشيخ زايد', 'type': 'compound', 'city': '6 أكتوبر', 'rollout_status': 'active'},
          {'id': 2, 'name_ar': 'بالم هيلز، أكتوبر', 'type': 'compound', 'city': '6 أكتوبر', 'rollout_status': 'active'},
          {'id': 3, 'name_ar': 'مدينة نصر', 'type': 'city_district', 'city': 'القاهرة', 'rollout_status': 'active'},
          {'id': 4, 'name_ar': 'التجمع الخامس', 'type': 'city_district', 'city': 'القاهرة الجديدة', 'rollout_status': 'coming_soon'},
        ],
      };
    }

    // ---- Rider auth ----
    if (method == 'POST' && path == '/rider/register') {
      _lastOtpPhone = body?['phone'];
      return {'message': 'تم الإرسال، كود التجربة هو 1234', 'phone': body?['phone']};
    }
    if (method == 'POST' && path == '/rider/verify-otp') {
      return {
        'token': 'demo-token-rider',
        'rider': {'id': 1, 'full_name': 'أحمد سامي', 'phone': body?['phone'] ?? _lastOtpPhone},
      };
    }
    if (method == 'POST' && path == '/rider/resend-otp') {
      return {'message': 'تم إعادة الإرسال، كود التجربة هو 1234'};
    }

    // ---- Trips ----
    if (method == 'POST' && path == '/rider/trips/estimate') {
      return {
        'distance_km': 8.4,
        'is_out_of_zone': false,
        'estimates': [
          {'category': 'economy', 'estimated_fare': 42},
          {'category': 'plus', 'estimated_fare': 58},
          {'category': 'family', 'estimated_fare': 75},
        ],
      };
    }
    if (method == 'POST' && path == '/rider/trips') {
      final id = _nextId();
      final trip = {
        'id': id,
        'status': 'searching',
        'category': body?['category'] ?? 'economy',
        'distance_km': 8.4,
        'estimated_fare': 42,
        'final_fare': null,
        'is_out_of_zone': false,
      };
      _trips[id] = trip;
      _tripCreatedAt[id] = DateTime.now();
      return {'trip': trip};
    }
    if (method == 'GET' && segments.length == 3 && segments[0] == 'rider' && segments[1] == 'trips') {
      final id = int.parse(segments[2]);
      final trip = _trips[id];
      if (trip == null) return {'trip': null};
      final elapsed = DateTime.now().difference(_tripCreatedAt[id]!).inSeconds;
      String status = trip['status'];
      if (status != 'cancelled') {
        if (elapsed >= 16) {
          status = 'completed';
          trip['final_fare'] = trip['estimated_fare'];
        } else if (elapsed >= 10) {
          status = 'in_progress';
        } else if (elapsed >= 5) {
          status = 'accepted';
        } else {
          status = 'searching';
        }
        trip['status'] = status;
      }
      return {'trip': trip};
    }
    if (method == 'POST' && segments.length == 4 && segments[1] == 'trips' && segments[3] == 'cancel') {
      final id = int.parse(segments[2]);
      _trips[id]?['status'] = 'cancelled';
      return {'message': 'تم الإلغاء'};
    }

    // ---- Packages ----
    if (method == 'GET' && path == '/rider/packages') {
      return {
        'packages': [
          {'id': 1, 'name': 'باقة 50 كم', 'km_included': 50, 'price': 180, 'validity_days': 30},
          {'id': 2, 'name': 'باقة 120 كم', 'km_included': 120, 'price': 380, 'validity_days': 30},
          {'id': 3, 'name': 'باقة المدرسة (شهرية)', 'km_included': 200, 'price': 550, 'validity_days': 30},
        ],
      };
    }
    if (method == 'POST' && segments.length == 3 && segments[1] == 'packages') {
      _ridersPackages.add({
        'id': _nextId(),
        'package_id': int.parse(segments[2]),
        'km_remaining': 50,
        'status': 'active',
        'expires_at': '2026-10-19',
      });
      return {'message': 'تم إنشاء طلب الشراء - في انتظار الدفع عبر Paymob'};
    }
    if (method == 'GET' && path == '/rider/my-packages') {
      return {'rider_packages': _ridersPackages};
    }

    // ---- Saved places ----
    if (method == 'GET' && path == '/rider/saved-places') {
      return {'saved_places': _savedPlaces};
    }
    if (method == 'POST' && path == '/rider/saved-places') {
      final place = {
        'id': _nextId(),
        'label': body?['label'],
        'address_text': body?['address_text'],
        'lat': 30.0,
        'lng': 31.0,
      };
      _savedPlaces.add(place);
      return {'saved_place': place};
    }
    if (method == 'DELETE' && segments.length == 3 && segments[1] == 'saved-places') {
      _savedPlaces.removeWhere((p) => p['id'] == int.parse(segments[2]));
      return {'message': 'تم الحذف'};
    }

    // ---- Carpool schedules ----
    if (method == 'GET' && path == '/rider/carpool-schedules') {
      return {'carpool_schedules': _carpoolSchedules};
    }
    if (method == 'POST' && path == '/rider/carpool-schedules') {
      final sched = {
        'id': _nextId(),
        'child_name': body?['child_name'],
        'school_name': body?['school_name'] ?? 'المدرسة',
        'pickup_time': body?['pickup_time'],
        'return_time': body?['return_time'],
        'days_of_week': body?['days_of_week'] ?? [],
        'status': 'active',
      };
      _carpoolSchedules.add(sched);
      return {'carpool_schedule': sched};
    }
    if (method == 'POST' && segments.length == 4 && segments[1] == 'carpool-schedules' && (segments[3] == 'pause' || segments[3] == 'resume')) {
      final id = int.parse(segments[2]);
      final sched = _carpoolSchedules.firstWhere((s) => s['id'] == id);
      sched['status'] = segments[3] == 'pause' ? 'paused' : 'active';
      return {'carpool_schedule': sched};
    }

    // ---- Wallet ----
    if (method == 'GET' && path == '/rider/wallet') {
      return {
        'wallet': {'balance': _walletBalance},
        'transactions': _walletTx,
      };
    }
    if (method == 'POST' && path == '/rider/wallet/topup') {
      final amount = double.tryParse(body?['amount'].toString() ?? '0') ?? 0;
      _walletBalance += amount;
      _walletTx.insert(0, {'id': _nextId(), 'type': 'credit', 'amount': amount, 'reason': 'topup', 'created_at': 'الآن'});
      return {'wallet': {'balance': _walletBalance}};
    }

    // ---- Ratings ----
    if (method == 'POST' && path == '/rider/ratings') {
      return {'message': 'شكرًا لتقييمك'};
    }

    // ---- Support tickets ----
    if (method == 'GET' && path == '/rider/support-tickets') {
      return {'support_tickets': _supportTickets};
    }
    if (method == 'POST' && path == '/rider/support-tickets') {
      final ticket = {
        'id': _nextId(),
        'category': body?['category'],
        'description': body?['description'],
        'status': 'open',
        'created_at': 'الآن',
      };
      _supportTickets.insert(0, ticket);
      return {'support_ticket': ticket};
    }

    // أي مسار غير معروف - رجّع استجابة فاضية بدل ما التطبيق يقع
    return {};
  }
}
